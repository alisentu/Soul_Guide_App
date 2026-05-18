import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Gradient progress bar - pill shaped
class GradientProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Gradient gradient;
  final Color trackColor;
  final BorderRadius? borderRadius;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.gradient = const LinearGradient(
      colors: [AppColors.tertiaryFixedDim, AppColors.tertiary],
    ),
    this.trackColor = AppColors.surfaceContainerHighest,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(height / 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: radius,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: height,
              width: constraints.maxWidth * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: radius,
              ),
            ),
          ],
        );
      },
    );
  }
}
