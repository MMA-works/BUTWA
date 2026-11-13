import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/features/transfer/data/transfer_remote_datasource.dart';
import 'package:batwa_wallet/features/transfer/presentation/screens/send_money_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  late AnimationController _animCtrl;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: true,
    );
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkPermissionAndStart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _scannerController.stop();
        break;
    }
  }

  Future<void> _checkPermissionAndStart() async {
    if (mounted) setState(() => _isCheckingPermission = true);
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _scannerController.start();
        } catch (e) {
          debugPrint('Error starting camera: $e');
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(String rawData) async {
    if (_isProcessing) return;
    _isProcessing = true;
    HapticFeedback.mediumImpact();

    // 🌟 Instant Client-Side QR Parsing
    String recipient = rawData.trim();
    double? suggestedAmount;
    String? note;

    if (recipient.startsWith('BATWA:')) {
      recipient = recipient.replaceFirst('BATWA:', '');
    }

    if (recipient.contains('?')) {
      final parts = recipient.split('?');
      recipient = parts[0];
      final queryParams = Uri.splitQueryString(parts[1]);
      if (queryParams.containsKey('amount')) {
        suggestedAmount = double.tryParse(queryParams['amount'] ?? '');
      }
      if (queryParams.containsKey('note')) {
        note = queryParams['note'];
      }
    }

    if (recipient.startsWith('{') && recipient.endsWith('}')) {
      try {
        final decoded = jsonDecode(recipient);
        if (decoded is Map) {
          recipient = (decoded['walletId'] ?? decoded['recipient'] ?? decoded['accountEmail'] ?? '').toString();
          if (decoded['amount'] != null) {
            suggestedAmount = double.tryParse(decoded['amount'].toString());
          }
          if (decoded['note'] != null) {
            note = decoded['note'].toString();
          }
        }
      } catch (_) {}
    }

    recipient = recipient.replaceAll(RegExp(r'^@+'), '').trim();

    if (recipient.isEmpty) {
      _isProcessing = false;
      return;
    }

    // Stop scanner while processing/navigating
    try {
      await _scannerController.stop();
    } catch (_) {}

    // Show quick progress indication if lookup takes a moment
    if (mounted) {
      setState(() {});
    }

    // Lookup recipient info in real-time
    String recipientName = 'BATWA Verified User';
    try {
      final datasource = TransferRemoteDataSourceImpl(apiClient: ApiClient());
      final res = await datasource.lookupRecipient(recipient);
      recipientName = res.recipientFullName;
      if (res.walletTag.isNotEmpty) {
        recipient = res.walletTag.replaceAll(RegExp(r'^@+'), '').trim();
      }
    } catch (e) {
      debugPrint('QR recipient lookup info: $e');
    }

    if (!mounted) return;

    // Retrieve sender context from state
    double balance = 0.0;
    String? sPhone;
    String? sTag;
    String? sTitle;
    try {
      final wState = context.read<WalletBloc>().state;
      if (wState is WalletLoaded) {
        balance = wState.wallet.balance;
        sTag = wState.wallet.walletTag;
      }
      final aState = context.read<AuthBloc>().state;
      if (aState is Authenticated) {
        sPhone = aState.user.phoneNumber;
        sTitle = aState.user.fullName;
      }
    } catch (_) {}

    // Open Send Money directly at Enter Amount step with recipient loaded
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendMoneyScreen(
          userBalance: balance,
          senderPhone: sPhone,
          senderTag: sTag,
          senderTitle: sTitle,
          initialRecipient: recipient,
          initialRecipientName: recipientName,
          initialAmount: suggestedAmount,
          initialNote: note,
        ),
      ),
    );

    // Restart scanner upon return
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      try {
        await _scannerController.start();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        actions: [
          if (_hasPermission)
            IconButton(
              onPressed: () async {
                await _scannerController.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
              icon: Icon(
                _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isTorchOn ? AppColors.primaryYellow : Colors.white70,
              ),
              tooltip: 'Toggle Flashlight',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isCheckingPermission) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryYellow, size: 36),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Camera Permission Needed',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Batwa requires camera access to scan QR codes for instant payments.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkPermissionAndStart,
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: const Text('Allow Camera Access'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.darkNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: openAppSettings,
                child: const Text('Open App Settings', style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera View
        MobileScanner(
          controller: _scannerController,
          fit: BoxFit.cover,
          errorBuilder: (context, error, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.primaryYellow, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Camera Error: ${error.errorCode}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _scannerController.start(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.darkNavy,
                      ),
                      child: const Text('Retry Camera', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            );
          },
          onDetect: (capture) {
            if (_isProcessing) return;
            for (final barcode in capture.barcodes) {
              final rawValue = (barcode.rawValue ?? barcode.displayValue ?? '').trim();
              if (rawValue.isNotEmpty && !_isProcessing) {
                _onQrDetected(rawValue);
                break;
              }
            }
          },
        ),

        // Viewfinder Frame & Animated Laser Scanline
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primaryYellow.withValues(alpha: 0.8),
                        width: 2.2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _animCtrl,
                          builder: (context, child) {
                            return Positioned(
                              top: _animCtrl.value * 230,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryYellow.withValues(alpha: 0.9),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Corner accents
                  Positioned(
                    top: -3,
                    left: -3,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                          left: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                          right: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -3,
                    left: -3,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                          left: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -3,
                    right: -3,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                          right: BorderSide(color: AppColors.primaryYellow, width: 4.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Align QR code within frame to scan',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              if (_isProcessing) ...[
                const SizedBox(height: 16),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
