import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/account_details_modal.dart';
import 'package:flutter/services.dart';

class BalanceCardWidget extends StatelessWidget {
  final WalletEntity wallet;
  final bool isBalanceHidden;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onSetBudget;
  final String? userName;
  final String? userPhone;
  final VoidCallback? onViewInfo;

  const BalanceCardWidget({
    super.key,
    required this.wallet,
    required this.isBalanceHidden,
    required this.onToggleVisibility,
    this.onSetBudget,
    this.userName,
    this.userPhone,
    this.onViewInfo,
  });

  @override
  Widget build(BuildContext context) {
    const cardHeight = 208.0;
    const stepDownY = 46.0;

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🌟 1. Stepped Asymmetric Dark Charcoal Navy Card Body
          Positioned.fill(
            child: CustomPaint(
              painter: SteppedCardShadowPainter(
                cornerRadius: 26.0,
                stepDownY: stepDownY,
                stepStartX: 0.58,
                stepEndX: 0.70,
              ),
              child: ClipPath(
                clipper: SteppedCardClipper(
                  cornerRadius: 26.0,
                  stepDownY: stepDownY,
                  stepStartX: 0.58,
                  stepEndX: 0.70,
                ),
                child: Container(
                  color: AppColors.darkNavy, // #1B1D28 Charcoal Navy
                  child: Stack(
                    children: [
                      // Subtle geometric chevron / herringbone wave texture
                      const Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: ChevronTexturePainter(),
                          ),
                        ),
                      ),

                      // 🌟 Mustard Sparkle Stars on Card
                      // Main large 4-point sparkle star near the top shoulder
                      const Positioned(
                        right: 120,
                        top: 26,
                        child: SparkleStar(size: 26, color: AppColors.primaryMustard),
                      ),

                      // Smaller subtle sparkle near middle right
                      Positioned(
                        right: 140,
                        top: 110,
                        child: SparkleStar(
                          size: 11,
                          color: AppColors.primaryMustard.withValues(alpha: 0.6),
                        ),
                      ),

                      // Subtle sparkle near bottom right
                      Positioned(
                        right: 80,
                        bottom: 44,
                        child: SparkleStar(
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),

                      // 🌟 Left & Center Card Data
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 80, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top VISA & Visibility Toggle
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/payment_networks/visa.png',
                                      height: 16,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Text(
                                        'VISA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: onToggleVisibility,
                                      behavior: HitTestBehavior.opaque,
                                      child: Icon(
                                        isBalanceHidden
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white.withValues(alpha: 0.5),
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Balance',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isBalanceHidden
                                      ? '••••••••'
                                      : CurrencyFormatter.format(wallet.balance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),

                            // Center Masked Card Number (Tap to View Account Info)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (onViewInfo != null) {
                                  onViewInfo!();
                                } else {
                                  AccountDetailsModal.show(
                                    context,
                                    fullName: userName ?? (wallet.walletTag.isNotEmpty ? wallet.walletTag : 'Batwa User'),
                                    walletTag: wallet.walletTag,
                                    phoneNumber: userPhone ?? '03219876543',
                                    currency: wallet.currency,
                                  );
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '••••   ••••   ••••   ${wallet.walletTag.length >= 4 ? wallet.walletTag.substring(wallet.walletTag.length - 4).toUpperCase() : '7281'}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.info_outline_rounded, size: 13, color: Colors.white.withValues(alpha: 0.45)),
                                ],
                              ),
                            ),

                            // Bottom Metadata (User Name & Expiry)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userName ?? (wallet.walletTag.isNotEmpty ? '@${wallet.walletTag}' : 'Batwa User'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Exp 07/28',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🌟 2. "+ Set Budget" Pill Button in the Top-Right Stepped Notch (Placed on top of Stack for hit-testing!)
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSetBudget,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMustard, // Warm Mustard Gold
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMustard.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.darkNavy,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add_rounded, size: 13, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Set Budget',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🌟 3. Right Vertical Interactive Pod (View Info & Copy Account/IBAN/Title/Bank)
          Positioned(
            right: 8,
            top: stepDownY + 8,
            bottom: 8,
            width: 58,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onViewInfo != null) {
                    onViewInfo!();
                  } else {
                    AccountDetailsModal.show(
                      context,
                      fullName: userName ?? (wallet.walletTag.isNotEmpty ? wallet.walletTag : 'Batwa User'),
                      walletTag: wallet.walletTag,
                      phoneNumber: userPhone ?? '03219876543',
                      currency: wallet.currency,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.black12,
                highlightColor: Colors.black.withValues(alpha: 0.05),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryMustard, // Solid #F5A623
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMustard.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          Icons.contactless_rounded,
                          size: 24,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkNavy,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: AppColors.primaryMustard,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'VIEW\nINFO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primaryMustard,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                height: 1.15,
                              ),
                            ),
                          ],
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
    );
  }
}

/// Custom Clipper that produces the stepped down asymmetric silhouette
class SteppedCardClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double stepDownY;
  final double stepStartX;
  final double stepEndX;

  SteppedCardClipper({
    this.cornerRadius = 26.0,
    this.stepDownY = 46.0,
    this.stepStartX = 0.58,
    this.stepEndX = 0.70,
  });

  @override
  Path getClip(Size size) {
    return _buildSteppedCardPath(size, cornerRadius, stepDownY, stepStartX, stepEndX);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom Painter to draw matching drop shadow for the stepped path
class SteppedCardShadowPainter extends CustomPainter {
  final double cornerRadius;
  final double stepDownY;
  final double stepStartX;
  final double stepEndX;

  SteppedCardShadowPainter({
    required this.cornerRadius,
    required this.stepDownY,
    required this.stepStartX,
    required this.stepEndX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildSteppedCardPath(size, cornerRadius, stepDownY, stepStartX, stepEndX);
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.35),
      14.0,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _buildSteppedCardPath(Size size, double r, double stepDownY, double startXFactor, double endXFactor) {
  final w = size.width;
  final h = size.height;
  final x1 = w * startXFactor;
  final x2 = w * endXFactor;
  final y2 = stepDownY;

  final path = Path();
  // Start at top-left corner
  path.moveTo(0, r);
  path.quadraticBezierTo(0, 0, r, 0);

  // Top left edge up to shoulder start
  path.lineTo(x1, 0);

  // Smooth S-curve transition downwards to stepDownY
  path.cubicTo(
    x1 + (x2 - x1) * 0.42, 0,
    x1 + (x2 - x1) * 0.58, y2,
    x2, y2,
  );

  // Top right lower edge
  path.lineTo(w - r, y2);
  path.quadraticBezierTo(w, y2, w, y2 + r);

  // Right edge down
  path.lineTo(w, h - r);
  path.quadraticBezierTo(w, h, w - r, h);

  // Bottom edge
  path.lineTo(r, h);
  path.quadraticBezierTo(0, h, 0, h - r);

  // Left edge up
  path.close();
  return path;
}

/// Painter for chevron herringbone texture
class ChevronTexturePainter extends CustomPainter {
  const ChevronTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 12.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      final path = Path();
      for (double y = 0; y < size.height; y += 16) {
        path.moveTo(x + y, y);
        path.lineTo(x + y + 8, y + 8);
        path.lineTo(x + y, y + 16);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4-pointed Sparkle Star Widget
class SparkleStar extends StatelessWidget {
  final double size;
  final Color color;

  const SparkleStar({super.key, this.size = 24, this.color = AppColors.primaryMustard});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparkleStarPainter(color: color),
    );
  }
}

class _SparkleStarPainter extends CustomPainter {
  final Color color;

  _SparkleStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final path = Path();
    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

