import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/bottom_nav_bar.dart';

class TestsScreen extends ConsumerWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(quizSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        title: Text('Testler',
            style: AppTypography.headlineLgMobile.copyWith(color: AppColors.onSurface)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Row(
              children: [
                _StatBadge(label: 'Tamamlanan', value: sessions.length.toString(), icon: Icons.check_circle_rounded, color: AppColors.tertiary),
                const SizedBox(width: AppSpacing.stackMd),
                _StatBadge(label: 'Bu Hafta', value: '1', icon: Icons.calendar_today_rounded, color: AppColors.primary),
                const SizedBox(width: AppSpacing.stackMd),
                _StatBadge(label: 'Puan', value: (sessions.length * 10).toString(), icon: Icons.star_rounded, color: AppColors.secondary),
              ],
            ),
          ),
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.psychology_rounded, size: 64, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.stackMd),
                        Text('Henüz test çözmedin', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text('İlk testini çöz!', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.stackLg),
                        GestureDetector(
                          onTap: () {
                            ref.read(quizSessionProvider.notifier).reset();
                            context.push('/weekly-quiz');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackLg, vertical: AppSpacing.stackMd),
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                            child: Text('Başlat', style: AppTypography.headlineSm.copyWith(color: AppColors.onPrimaryFixed, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.stackMd),
                    itemBuilder: (_, i) {
                      final s = sessions[sessions.length - 1 - i];
                      final isWeekly = s['isWeekly'] as bool? ?? false;
                      final startedAt = s['startedAt'] as String?;
                      final date = startedAt != null ? DateTime.parse(startedAt) : DateTime.now();
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.stackMd),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackSm, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isWeekly ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.tertiaryContainer.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: Text(isWeekly ? 'Haftalık' : 'Onboarding',
                                      style: AppTypography.labelCaps.copyWith(color: isWeekly ? AppColors.primary : AppColors.tertiary, fontSize: 10)),
                                ),
                                const Spacer(),
                                Text('${date.day}/${date.month}/${date.year}', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.stackSm),
                            Text(isWeekly ? 'Haftalık Davranış Testi' : 'İlk Profil Analizi',
                                style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontSize: 16)),
                            const SizedBox(height: AppSpacing.stackSm),
                            GradientProgressBar(value: 1.0, height: 4),
                            const SizedBox(height: 4),
                            Text('Tamamlandı ✓', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 2),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBadge({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.headlineLgMobile.copyWith(color: color, fontSize: 20)),
            Text(label, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant, fontSize: 9), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
