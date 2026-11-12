import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'my_qr_screen.dart';
import '../bloc/qr_bloc.dart';
import '../bloc/qr_event.dart';
import '../bloc/qr_state.dart';
import '../widgets/qr_payment_sheet.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  late AnimationController _animCtrl;
  final _manualInputCtrl = TextEditingController();
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
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: false,
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
    _manualInputCtrl.dispose();
    super.dispose();
  }

  void _onQrDetected(String rawData) {
    if (_isProcessing) return;
    _isProcessing = true;
    HapticFeedback.mediumImpact();
    if (rawData.isNotEmpty) {
      context.read<QrBloc>().add(ParseQrCodeEvent(rawQrData: rawData));
    } else {
      _isProcessing = false;
    }
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enter or Paste QR Payload', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _manualInputCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                hintText: 'Paste raw JSON or QR payload here...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        _manualInputCtrl.text = data!.text!;
                      }
                    },
                    icon: const Icon(Icons.paste_rounded, size: 16, color: AppColors.primaryYellow),
                    label: const Text('Paste Clipboard', style: TextStyle(color: AppColors.primaryYellow, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryYellow),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _manualInputCtrl.text.trim();
              Navigator.of(ctx).pop();
              if (text.isNotEmpty) {
                _onQrDetected(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.darkNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Process Code', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: TextButton.icon(
              onPressed: () {
                _scannerController.stop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MyQrScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_2_rounded, size: 16, color: Color(0xFF10B981)),
              label: const Text(
                'My QR',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 11.5),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.16),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (_hasPermission) ...[
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
            IconButton(
              onPressed: () => _scannerController.switchCamera(),
              icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70),
              tooltip: 'Flip Camera',
            ),
          ],
          IconButton(
            onPressed: _showManualInputDialog,
            icon: const Icon(Icons.keyboard_rounded, color: Colors.white70),
            tooltip: 'Enter code manually',
          ),
        ],
      ),
      body: BlocConsumer<QrBloc, QrState>(
        listener: (context, state) {
          if (state is QrParsedState) {
            _isProcessing = false;
            if (!state.preview.isValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.preview.validationMessage),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<QrBloc>(),
                  child: QrPaymentSheet(preview: state.preview),
                ),
              ).then((_) {
                _isProcessing = false;
              });
            }
          } else if (state is QrErrorState) {
            _isProcessing = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isParsing = state is QrLoadingState;

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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryYellow, size: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Camera Permission Needed',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Batwa requires camera access to scan QR codes for instant payments and contactless transfers.',
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
                            'Camera Error: ${error.errorCode}\n${error.errorDetails?.message ?? ""}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _scannerController.start();
                            },
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
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final rawValue = barcode.rawValue;
                    if (rawValue != null && rawValue.isNotEmpty) {
                      _isProcessing = true;
                      _onQrDetected(rawValue);
                      break;
                    }
                  }
                },
              ),

              // 🌟 LAYER 2: Viewfinder Frame & Animated Laser Scanline
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Viewfinder Frame
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.primaryYellow.withValues(alpha: 0.8),
                              width: 2.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Animated Laser Scanline
                              AnimatedBuilder(
                                animation: _animCtrl,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _animCtrl.value * 240,
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

                        // Corner highlights
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
                    const SizedBox(height: 24),
                    const Text(
                      'Align QR code within frame to scan',
                      style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Supports Instant BATWA P2P & Dynamic Requests',
                      style: TextStyle(color: Colors.white54, fontSize: 11.5),
                    ),
                  ],
                ),
              ),

              // 🌟 LAYER 3: Bottom Quick Actions Panel
              Positioned(
                bottom: 34,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    if (isParsing)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: CircularProgressIndicator(color: AppColors.primaryYellow),
                      ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _scannerController.stop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MyQrScreen()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_2_rounded, size: 20, color: Color(0xFF10B981)),
                      label: const Text(
                        'Show My QR Code (Receive Money) 📥',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.16),
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showManualInputDialog,
                            icon: const Icon(Icons.paste_rounded, size: 18),
                            label: const Text('Paste Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF191B21),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              const testQr = '{"walletId":"01c478e9-c02e-4d67-8535-46bea3c1e0db","accountEmail":"merchant@batwa.com","accountName":"Star Coffee Merchant","type":"P2P_DYNAMIC","amount":450.0,"note":"Iced Caramel Macchiato"}';
                              _onQrDetected(testQr);
                            },
                            icon: const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFF1B1D28)),
                            label: const Text('Test Scan', style: TextStyle(color: Color(0xFF1B1D28), fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


