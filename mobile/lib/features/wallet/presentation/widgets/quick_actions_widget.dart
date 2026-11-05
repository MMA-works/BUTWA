import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onQr;
  final VoidCallback onBill;

  const QuickActionsWidget({
    super.key,
    required this.onSend,
    required this.onQr,
    required this.onBill,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 🌟 Background Capsule Container
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🌟 Left Action: Send Money
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSend,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                      child: Container(
                        padding: const EdgeInsets.only(right: 28),
                        alignment: Alignment.center,
                        child: Text(
                          'Send Money',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.darkNavy,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Space for center circle
                const SizedBox(width: 44),

                // 🌟 Right Action: Pay Bills
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBill,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                      child: Container(
                        padding: const EdgeInsets.only(left: 28),
                        alignment: Alignment.center,
                        child: Text(
                          'Pay Bills',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.darkNavy,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🌟 Enlarged Prominent Center QR Scanner Circle
          GestureDetector(
            onTap: onQr,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFF191B21), // Deep Matte Charcoal Dark
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



