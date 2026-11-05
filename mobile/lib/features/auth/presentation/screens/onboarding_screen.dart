import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/auth/presentation/screens/login_screen.dart';
import 'package:batwa_wallet/features/auth/presentation/screens/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundSurface,
      body: Row(
        children: [
          // 🌟 1. Left Visual Banner (Bauhaus / Memphis Geometric Mosaic ~30% width)
          SizedBox(
            width: size.width * 0.30,
            height: size.height,
            child: const CustomPaint(
              painter: BauhausMosaicPainter(),
            ),
          ),

          // 🌟 2. Right Content Section (~70% width)
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top-Right Aligned Header Bar (Time + Weather + Date)
                    Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '06:20 PM',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.darkNavy,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('☀️', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 4),
                                    Text(
                                      '34° C',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryMustard,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nov. 10.2020 | Wednesday',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Center Brand Identity
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'BATWA',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.darkNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Value proposition text
                    Text(
                      'Open An Account For Digital E-Wallet Solutions. Instant Payouts.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.darkNavy.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Secondary helper link: "Join For Free."
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Join For Free',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryMustard,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primaryMustard),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom Actions
                    // 1. Primary Solid Mustard Pill Button: Sign in →
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMustard,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Secondary Text Button: Create an account
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.darkNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Bauhaus / Memphis Geometric Mosaic Painter for Left Split Banner
class BauhausMosaicPainter extends CustomPainter {
  const BauhausMosaicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintCoral = Paint()..color = AppColors.accentCoral;
    final paintCyan = Paint()..color = AppColors.accentCyan;
    final paintMustard = Paint()..color = AppColors.primaryMustard;
    final paintNavy = Paint()..color = AppColors.darkNavy;
    final paintSkyBlue = Paint()..color = AppColors.accentSkyBlue;

    // Background base
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF1F3F5));

    // Block 1: Top Navy Quarter Circle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: w * 0.9),
      0,
      3.14159 / 2,
      true,
      paintNavy,
    );

    // Block 2: Coral Semi-Circle
    canvas.drawArc(
      Rect.fromLTWH(-w * 0.2, h * 0.12, w * 1.1, w * 1.1),
      -3.14159 / 2,
      3.14159,
      true,
      paintCoral,
    );

    // Block 3: Diagonal 45-degree angle slice (Cyan)
    final path1 = Path()
      ..moveTo(0, h * 0.28)
      ..lineTo(w, h * 0.36)
      ..lineTo(w, h * 0.44)
      ..lineTo(0, h * 0.36)
      ..close();
    canvas.drawPath(path1, paintCyan);

    // Block 4: Mustard Full Circle
    canvas.drawCircle(Offset(w * 0.55, h * 0.52), w * 0.36, paintMustard);

    // Block 5: Navy Pill Block
    final rrect1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.3, h * 0.62, w * 1.1, h * 0.08),
      const Radius.circular(24),
    );
    canvas.drawRRect(rrect1, paintNavy);

    // Block 6: Sky Blue & Coral Diagonal geometric slice
    final path2 = Path()
      ..moveTo(w, h * 0.73)
      ..lineTo(0, h * 0.81)
      ..lineTo(0, h * 0.89)
      ..lineTo(w, h * 0.81)
      ..close();
    canvas.drawPath(path2, paintSkyBlue);

    // Block 7: Bottom Cyan Half Circle
    canvas.drawArc(
      Rect.fromLTWH(-w * 0.3, h * 0.90, w * 1.2, w * 1.2),
      -3.14159 / 2,
      3.14159,
      true,
      paintCyan,
    );

    // Block 8: Coral accent dot
    canvas.drawCircle(Offset(w * 0.65, h * 0.86), w * 0.18, paintCoral);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
