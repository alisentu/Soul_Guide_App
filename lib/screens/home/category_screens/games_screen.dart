import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/game.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../widgets/skeleton_loader.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Oyun ara...',
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                  border: InputBorder.none,
                ),
                onChanged: (q) {
                  if (q.length > 2) {
                    ref.read(gameSearchProvider.notifier).search(q);
                  }
                },
              )
            : Text('Oyunlar',
                style: AppTypography.headlineLgMobile
                    .copyWith(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.onSurface,
            ),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchCtrl.clear();
                ref.read(gameSearchProvider.notifier).clear();
              }
            },
          ),
        ],
      ),
      body: _isSearching ? _buildSearch() : _buildList(),
    );
  }

  Widget _buildList() {
    final gamesAsync = ref.watch(gamesProvider);
    return gamesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.marginMobile),
        child: SkeletonList(count: 5, cardHeight: 120),
      ),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(gamesProvider),
      ),
      data: (games) => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.stackMd),
        itemBuilder: (_, i) => _GameCard(game: games[i]),
      ),
    );
  }

  Widget _buildSearch() {
    final searchAsync = ref.watch(gameSearchProvider);
    return searchAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.marginMobile),
        child: SkeletonList(count: 5, cardHeight: 100),
      ),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
      data: (results) => results.isEmpty
          ? Center(
              child: Text('Sonuç bulunamadı',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant)))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.stackMd),
              itemBuilder: (_, i) => _GameCard(game: results[i]),
            ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final steamUrl = 'https://store.steampowered.com/search/?term=${Uri.encodeComponent(game.name)}';
        launchUrl(Uri.parse(steamUrl), mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: game.backgroundImage != null
                  ? CachedNetworkImage(
                      imageUrl: game.backgroundImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.surfaceContainerHigh),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.sports_esports_rounded,
                          color: AppColors.secondary),
                    ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.name,
                      style: AppTypography.headlineSm
                          .copyWith(color: AppColors.onSurface, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (game.rating != null)
                    Text('⭐ ${game.rating!.toStringAsFixed(1)}',
                        style: AppTypography.labelSm),
                  if (game.genres.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: game.genres.take(2).map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(g,
                              style: AppTypography.labelCaps.copyWith(
                                  color: AppColors.secondary, fontSize: 10)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded,
                color: AppColors.onSurfaceVariant, size: 16),
          ],
        ),
      ),
    );
  }
}
