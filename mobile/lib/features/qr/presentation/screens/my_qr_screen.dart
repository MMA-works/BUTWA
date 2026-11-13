import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<QrBloc>().add(const FetchMyQrCodeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My QR Code',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<QrBloc, QrState>(
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
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            );
          }

          final name = staticQr.accountName.isNotEmpty ? staticQr.accountName : 'BATWA User';
          final tag = staticQr.accountEmail.isNotEmpty ? staticQr.accountEmail : '';
          final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'BW';

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User Avatar with Initials
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // User Name
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (tag.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        tag.startsWith('@') ? tag : '@$tag',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Compact QR Code Container (Scans cleanly!)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: staticQr.rawQrData,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0F172A),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Verified Badge & Subtitle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                          SizedBox(width: 5),
                          Text(
                            'BATWA Instant P2P Identity',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Scan to pay me with BATWA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
