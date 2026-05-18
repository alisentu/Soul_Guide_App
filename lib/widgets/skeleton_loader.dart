import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';

/// Skeleton loading card
class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = AppSpacing.radiusDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surfaceContainerHighest,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton list of cards
class SkeletonList extends StatelessWidget {
  final int count;
  final double cardHeight;

  const SkeletonList({
    super.key,
    this.count = 3,
    this.cardHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
        child: SkeletonCard(height: cardHeight),
      ),
    );
  }
}

/// Horizontal skeleton scroll
class SkeletonHorizontalList extends StatelessWidget {
  final int count;
  final double itemWidth;
  final double itemHeight;

  const SkeletonHorizontalList({
    super.key,
    this.count = 4,
    this.itemWidth = 140,
    this.itemHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
        itemCount: count,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.stackMd),
        itemBuilder: (context, i) => SkeletonCard(
          width: itemWidth,
          height: itemHeight,
          borderRadius: AppSpacing.radiusLg,
        ),
      ),
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.message = 'Bir hata oluştu.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.stackLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.stackMd),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Tekrar Dene',
                  style: TextStyle(color: AppColors.primaryFixedDim),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
