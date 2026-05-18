import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/user_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final sessions = ref.watch(quizSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.0, -1.0),
                radius: 1.5,
                colors: [Color(0x33416086), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.stackMd,
                AppSpacing.marginMobile,
                100,
              ),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.stackLg),
                    decoration: BoxDecoration(
                      color: AppColors.glassCardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.glassCardBorder),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
                            ),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'U',
                              style: AppTypography.headlineLg.copyWith(color: AppColors.onPrimary, fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackMd),
                        Text(
                          profile?.name ?? 'Kullanıcı',
                          style: AppTypography.headlineLgMobile.copyWith(color: AppColors.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        if (profile?.archetypeLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd, vertical: AppSpacing.unit),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              border: Border.all(color: AppColors.primaryFixedDim.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              profile!.archetypeLabel!,
                              style: AppTypography.labelLg.copyWith(color: AppColors.primaryFixedDim),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.stackMd),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ProfileStat(label: 'Test', value: sessions.length.toString(), icon: Icons.psychology_rounded, color: AppColors.primary),
                            _ProfileStat(label: 'Seri', value: '${profile?.streak ?? 0}🔥', icon: Icons.local_fire_department_rounded, color: AppColors.secondary),
                            _ProfileStat(label: 'Puan', value: '${sessions.length * 10}', icon: Icons.star_rounded, color: AppColors.tertiary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Interest tags
                  if (profile?.interestTags.isNotEmpty == true) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('İlgi Alanları', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontSize: 16)),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Wrap(
                      spacing: AppSpacing.stackSm,
                      runSpacing: AppSpacing.stackSm,
                      children: profile!.interestTags.take(12).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd, vertical: AppSpacing.unit),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Text(tag, style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Summary
                  if (profile?.archetypeSummary != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.stackMd),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kişilik Özeti', style: AppTypography.labelLg.copyWith(color: AppColors.primaryFixedDim)),
                          const SizedBox(height: AppSpacing.stackSm),
                          Text(profile!.archetypeSummary!,
                              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Settings
                  _SettingsItem(icon: Icons.notifications_rounded, label: 'Bildirimler', onTap: () {}),
                  const SizedBox(height: AppSpacing.stackSm),
                  _SettingsItem(icon: Icons.privacy_tip_rounded, label: 'Gizlilik', onTap: () {}),
                  const SizedBox(height: AppSpacing.stackSm),
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Çıkış Yap',
                    color: AppColors.error,
                    onTap: () async {
                      await ref.read(storageServiceProvider).clearAll();
                      if (context.mounted) context.go('/welcome');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 4),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _ProfileStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineLgMobile.copyWith(color: color, fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SettingsItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd, vertical: AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: AppSpacing.stackMd),
            Text(label, style: AppTypography.bodyMd.copyWith(color: c)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
