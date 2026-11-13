import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
import 'package:batwa_wallet/features/qr/presentation/screens/qr_scanner_screen.dart';
import '../../domain/entities/qr_payload_entity.dart';
import '../bloc/qr_bloc.dart';
import '../bloc/qr_event.dart';
import '../bloc/qr_state.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  String _cachedWalletTag = '';

  @override
  void initState() {
    super.initState();
    context.read<QrBloc>().add(const FetchMyQrCodeEvent());
    _loadTag();
  }

  Future<void> _loadTag() async {
    final tag = await SecureStorageHelper.getWalletTag();
    if (tag != null && tag.isNotEmpty && mounted) {
      setState(() {
        _cachedWalletTag = tag;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1B1D28), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My QR Code',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1B1D28)),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, size: 16, color: Color(0xFFB48A00)),
                      SizedBox(width: 4),
                      Text(
                        'Scan & Pay',
                        style: TextStyle(
                          color: Color(0xFFB48A00),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tab matching screenshot (Dynamic Amount Request removed)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal ID QR',
                  style: TextStyle(
                    color: Color(0xFFB48A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: 98,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          Expanded(
            child: BlocConsumer<QrBloc, QrState>(
              listener: (context, state) {
                if (state is QrErrorState) {
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
                if (state is QrLoadingState) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
                }

                QrPayloadEntity? staticQr;
                if (state is MyQrLoadedState) {
                  staticQr = state.staticQr;
                }

                if (staticQr == null) {
                  return const Center(
                    child: Text(
                      'No QR Code available',
                      style: TextStyle(color: Color(0xFF8F92A1), fontSize: 14),
                    ),
                  );
                }

                // Resolve tag cleanly
                String tag = '';
                if (_cachedWalletTag.isNotEmpty) {
                  tag = _cachedWalletTag;
                } else if (staticQr.accountEmail.isNotEmpty) {
                  tag = staticQr.accountEmail;
                }
                if (tag.isEmpty || tag == 'user' || tag == 'batwa_user') {
                  tag = 'batwa_user';
                }
                final displayTag = tag.startsWith('@') ? tag : '@$tag';

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 360),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Small rounded yellow icon + @username
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF9C3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Color(0xFFB48A00),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayTag,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Large Clean QR Code
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: staticQr.rawQrData,
                              version: QrVersions.auto,
                              size: 230,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF1B1D28),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF1B1D28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // BATWA Verified P2P Identity pill badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14,
                                  color: Color(0xFFD97706),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'BATWA Verified P2P Identity',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD97706),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
