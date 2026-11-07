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

    // Batwa signature palette
    const goldPrimary = Color(0xFFF3D602);
    final bgDark = const Color(0xFF0C0F17);
    final bgLight = const Color(0xFFFAFAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: Stack(
        children: [
          // 🌟 1. Subtle Ambient Brand Glows
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.85,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    goldPrimary.withValues(alpha: isDark ? 0.12 : 0.18),
                    goldPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2D3).withValues(alpha: isDark ? 0.06 : 0.08),
                    const Color(0xFF00D2D3).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 🌟 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // 🌟 Centered Hero Logo
                  Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: goldPrimary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🌟 Brand Name & Tagline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BATWA',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? goldPrimary.withValues(alpha: 0.2) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'WALLET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? goldPrimary : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Smart Digital Banking & Instant Payouts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feature Pills
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFeaturePill('⚡ Raast Instant P2P', isDark),
                      _buildFeaturePill('💳 Contactless NFC Cards', isDark),
                      _buildFeaturePill('🧾 1-Tap Bill Payments', isDark),
                    ],
                  ),

                  const Spacer(flex: 4),

                  // 🌟 3. Bottom Action Buttons (Sign In & Sign Up / Register)
                  // Primary: Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldPrimary,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 4,
                        shadowColor: goldPrimary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary: Register / Create an Account
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Create an Account (Register)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Security Watermark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Protected by 256-bit State Bank Security • Raast 2.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white38 : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
      ),
    );
  }
}
