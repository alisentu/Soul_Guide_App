import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/user_provider.dart';

/// Haftalık Görev Kartı - Hero card at top of home
class WeeklyTaskCard extends ConsumerWidget {
  final VoidCallback onStartTest;

  const WeeklyTaskCard({super.key, required this.onStartTest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final lastTest = storage.getLastWeeklyTestDate();
    final daysLeft = lastTest != null
        ? 7 - DateTime.now().difference(lastTest).inDays
        : 0;
    final isDue = storage.isWeeklyTestDue;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.15),
            AppColors.secondaryContainer.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          // Decorative blob
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Background icon
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.stackMd),
              child: Icon(
                Icons.psychology_rounded,
                size: 100,
                color: AppColors.onSurface.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.stackMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.stackSm,
                        vertical: AppSpacing.unit,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        'Haftalık Görev',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.primaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.stackSm),
                    if (!isDue)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$daysLeft Gün Kaldı',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                Text(
                  isDue
                      ? 'Mini teste hazır mısın?'
                      : 'Harika iş!',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.stackSm),
                Text(
                  isDue
                      ? 'Bu haftaki kişisel gelişim yolculuğun için özel olarak hazırlanmış testimiz seni bekliyor.'
                      : 'Bu haftaki testini tamamladın. Sıradaki test ${daysLeft > 0 ? "$daysLeft gün" : "yarın"} gelecek.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.stackMd),
                if (isDue)
                  GestureDetector(
                    onTap: onStartTest,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.stackSm,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF366758),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hemen Başlat',
                            style: AppTypography.labelLg.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.stackSm),
                          const Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
