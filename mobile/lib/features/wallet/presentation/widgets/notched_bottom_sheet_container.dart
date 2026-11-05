import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';

class NotchedBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const NotchedBottomSheetContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Adaptive Container
        Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 90),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: child,
        ),

        // Signature Top-Center Semi-Circular Curved Notch Cutout
        Positioned(
          top: -1,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 52,
              height: 16,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Center(
                child: Container(
                  width: 22,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                        : AppColors.lightTextSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
