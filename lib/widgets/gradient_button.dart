import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';

/// Gradient pill-shaped buton
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final Gradient gradient;
  final Color textColor;
  final double height;
  final bool isLoading;
  final bool isFullWidth;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.gradient = AppColors.primaryGradient,
    this.textColor = AppColors.onPrimaryFixed,
    this.height = 56,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            else ...[
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.stackSm),
                icon!,
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Solid pill buton (tonal)
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? icon;
  final bool isSelected;

  const PillButton({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor = AppColors.surfaceContainer,
    this.foregroundColor = AppColors.onSurfaceVariant,
    this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.stackSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer
              : backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.5)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.labelLg.copyWith(
                  color: isSelected
                      ? AppColors.onSecondaryContainer
                      : foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
