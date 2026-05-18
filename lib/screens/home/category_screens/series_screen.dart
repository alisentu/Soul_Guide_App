import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/movie_series.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../../widgets/glass_card.dart';

/// Diziler & Filmler kategori ekranı
class SeriesScreen extends ConsumerStatefulWidget {
  const SeriesScreen({super.key});

  @override
  ConsumerState<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends ConsumerState<SeriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                  hintText: 'Dizi veya film ara...',
                  hintStyle: AppTypography.bodyMd
                      .copyWith(color: AppColors.outline),
                  border: InputBorder.none,
                ),
                onChanged: (q) {
                  if (q.length > 2) {
                    ref.read(movieSearchProvider.notifier).search(q);
                  }
                },
              )
            : Text(
                'Diziler & Filmler',
                style: AppTypography.headlineLgMobile
                    .copyWith(color: AppColors.onSurface),
              ),
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
                ref.read(movieSearchProvider.notifier).clear();
              }
            },
          ),
        ],
        bottom: !_isSearching
            ? TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primaryFixedDim,
                labelStyle: AppTypography.labelLg,
                tabs: const [Tab(text: 'Filmler'), Tab(text: 'Diziler')],
              )
            : null,
      ),
      body: _isSearching ? _buildSearchResults() : _buildTabView(),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _MovieList(type: 'movie'),
        _MovieList(type: 'tv'),
      ],
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(movieSearchProvider);
    return searchAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.marginMobile),
        child: SkeletonList(count: 5, cardHeight: 120),
      ),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text(
              'Arama sonucu bulunamadı',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          itemCount: results.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.stackMd),
          itemBuilder: (_, i) => _MovieCard(item: results[i]),
        );
      },
    );
  }
}

class _MovieList extends ConsumerWidget {
  final String type;
  const _MovieList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData =
        type == 'movie' ? ref.watch(moviesProvider) : ref.watch(seriesProvider);

    return asyncData.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.marginMobile),
        child: SkeletonList(count: 6, cardHeight: 120),
      ),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => type == 'movie'
            ? ref.refresh(moviesProvider)
            : ref.refresh(seriesProvider),
      ),
      data: (items) => GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: AppSpacing.stackMd,
          mainAxisSpacing: AppSpacing.stackMd,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _MovieGridCard(item: items[i]),
      ),
    );
  }
}

class _MovieGridCard extends StatelessWidget {
  final MovieSeries item;
  const _MovieGridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/series-detail', extra: item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.posterUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: item.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceContainerHigh,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Icon(Icons.movie_rounded,
                        color: AppColors.onSurfaceVariant),
                  ),
                ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.stackSm),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [AppColors.background, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '⭐ ${item.voteAverage.toStringAsFixed(1)}',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieSeries item;
  const _MovieCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/series-detail', extra: item),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: CachedNetworkImage(
              imageUrl: item.posterUrl,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 60, height: 90, color: AppColors.surfaceContainerHigh),
            ),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTypography.headlineSm
                        .copyWith(color: AppColors.onSurface, fontSize: 15)),
                const SizedBox(height: 4),
                Text('⭐ ${item.voteAverage.toStringAsFixed(1)}',
                    style: AppTypography.labelSm),
                const SizedBox(height: 4),
                Text(item.overview,
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dizi/Film Detay Ekranı
class SeriesDetailScreen extends ConsumerWidget {
  final MovieSeries item;
  const SeriesDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tmdb = ref.watch(tmdbServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.backdropUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: item.backdropUrl,
                      fit: BoxFit.cover,
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(item.title,
                    style: AppTypography.headlineLg
                        .copyWith(color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.stackSm),
                Text('⭐ ${item.voteAverage.toStringAsFixed(1)}  •  ${item.mediaType == 'tv' ? 'Dizi' : 'Film'}',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.stackMd),
                Text(item.overview,
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant, height: 1.6)),
                const SizedBox(height: AppSpacing.stackLg),
                Text('Nerede İzlenir?',
                    style: AppTypography.headlineSm
                        .copyWith(color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.stackMd),
                FutureBuilder<List<WatchProvider>>(
                  future: tmdb.getWatchProviders(item.id, type: item.mediaType),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SkeletonCard(height: 60);
                    }
                    final providers = snapshot.data ?? [];
                    if (providers.isEmpty) {
                      return Text('Platform bilgisi bulunamadı',
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.onSurfaceVariant));
                    }
                    return Wrap(
                      spacing: AppSpacing.stackMd,
                      runSpacing: AppSpacing.stackMd,
                      children: providers.map((p) {
                        return GestureDetector(
                          onTap: p.link != null
                              ? () => launchUrl(Uri.parse(p.link!))
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.stackMd,
                              vertical: AppSpacing.stackSm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull),
                              border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (p.logoUrl.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: p.logoUrl,
                                    width: 24,
                                    height: 24,
                                  ),
                                const SizedBox(width: 8),
                                Text(p.providerName,
                                    style: AppTypography.labelLg.copyWith(
                                        color: AppColors.onSurface)),
                                if (p.link != null) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.open_in_new_rounded,
                                      size: 12,
                                      color: AppColors.primaryFixedDim),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
