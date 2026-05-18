import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton_loader.dart';

/// "Senin İçin Seçtiklerimiz" Bento Grid
class DailyPicksSection extends ConsumerWidget {
  const DailyPicksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(dailyPickMovieProvider);
    final gameAsync = ref.watch(dailyPickGameProvider);
    final bookAsync = ref.watch(dailyPickBookProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      child: Column(
        children: [
          // Game pick
          gameAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.stackMd),
              child: SkeletonCard(height: 80),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (game) => game == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    child: _DailyPickRow(
                      title: 'Günün Oyunu',
                      subtitle: game.name,
                      description: game.genres.take(2).join(', '),
                      icon: Icons.sports_esports_rounded,
                      iconBg:
                          AppColors.secondaryContainer.withValues(alpha: 0.2),
                      iconColor: AppColors.secondaryFixedDim,
                      onTap: () => context.push('/category/games'),
                    ),
                  ),
          ),
          // Movie pick
          movieAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.stackMd),
              child: SkeletonCard(height: 80),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (movie) => movie == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    child: _DailyPickRow(
                      title: 'Günün Dizisi',
                      subtitle: movie.title,
                      description: '⭐ ${movie.voteAverage.toStringAsFixed(1)}',
                      icon: Icons.movie_rounded,
                      iconBg: AppColors.primaryContainer.withValues(alpha: 0.2),
                      iconColor: AppColors.primaryFixedDim,
                      onTap: () => context.push('/category/series'),
                    ),
                  ),
          ),
          // Book pick
          bookAsync.when(
            loading: () => const SkeletonCard(height: 80),
            error: (_, __) => const SizedBox.shrink(),
            data: (book) => book == null
                ? const SizedBox.shrink()
                : _DailyPickRow(
                    title: 'Günün Kitabı',
                    subtitle: book.title,
                    description: book.authorsString,
                    icon: Icons.menu_book_rounded,
                    iconBg: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                    iconColor: AppColors.tertiaryFixedDim,
                    onTap: () => context.push('/category/books'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DailyPickRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _DailyPickRow({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.outline,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
