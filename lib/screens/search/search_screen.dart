import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../providers/recommendations_provider.dart';
import '../../models/movie_series.dart';
import '../../models/game.dart';
import '../../models/book.dart';
import '../../widgets/bottom_nav_bar.dart';

// ─── SEARCH STATE ─────────────────────────────────────────────────────────

enum SearchCategory { all, movies, series, games, books }

class SearchState {
  final String query;
  final SearchCategory category;
  final bool isLoading;
  final List<SearchResult> results;

  const SearchState({
    this.query = '',
    this.category = SearchCategory.all,
    this.isLoading = false,
    this.results = const [],
  });

  SearchState copyWith({
    String? query,
    SearchCategory? category,
    bool? isLoading,
    List<SearchResult>? results,
  }) =>
      SearchState(
        query: query ?? this.query,
        category: category ?? this.category,
        isLoading: isLoading ?? this.isLoading,
        results: results ?? this.results,
      );
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchCategory type;
  final double? rating;
  final String? extra; // genres, authors, etc.

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.type,
    this.rating,
    this.extra,
  });
}

class SearchNotifierGlobal extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifierGlobal(this._ref) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: query, results: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, results: []);

    final results = <SearchResult>[];

    try {
      // Paralel arama
      final futures = await Future.wait([
        _searchMovies(query),
        _searchSeries(query),
        _searchGames(query),
        _searchBooks(query),
      ]);

      for (final list in futures) {
        results.addAll(list);
      }
    } catch (_) {}

    state = state.copyWith(isLoading: false, results: results);
  }

  Future<List<SearchResult>> _searchMovies(String query) async {
    try {
      _ref.read(movieSearchProvider.notifier).search(query);
      await Future.delayed(const Duration(milliseconds: 800));
      final state = _ref.read(movieSearchProvider);
      return state.whenOrNull(data: (list) {
        return list
            .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
            .map((m) => SearchResult(
                  id: m.id.toString(),
                  title: m.title,
                  subtitle: m.overview.isNotEmpty
                      ? m.overview.substring(0, m.overview.length.clamp(0, 80))
                      : 'Film',
                  imageUrl: (m.posterPath?.isNotEmpty == true)
                      ? 'https://image.tmdb.org/t/p/w200${m.posterPath}'
                      : null,
                  type: SearchCategory.movies,
                  rating: m.voteAverage,
                ))
            .toList();
      }) ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchSeries(String query) async {
    try {
      // Cached series'te ara
      final seriesState = _ref.read(seriesProvider);
      return seriesState.whenOrNull(data: (list) {
        return list
            .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
            .map((m) => SearchResult(
                  id: 'tv_${m.id}',
                  title: m.title,
                  subtitle: m.overview.isNotEmpty
                      ? m.overview.substring(0, m.overview.length.clamp(0, 80))
                      : 'Dizi',
                  imageUrl: (m.posterPath?.isNotEmpty == true)
                      ? 'https://image.tmdb.org/t/p/w200${m.posterPath}'
                      : null,
                  type: SearchCategory.series,
                  rating: m.voteAverage,
                ))
            .toList();
      }) ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchGames(String query) async {
    try {
      _ref.read(gameSearchProvider.notifier).search(query);
      await Future.delayed(const Duration(milliseconds: 800));
      final gState = _ref.read(gameSearchProvider);
      return gState.whenOrNull(data: (list) {
        return list
            .map((g) => SearchResult(
                  id: 'game_${g.id}',
                  title: g.name,
                  subtitle: g.genres.join(', '),
                  imageUrl: g.backgroundImage,
                  type: SearchCategory.games,
                  rating: g.rating,
                ))
            .toList();
      }) ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchBooks(String query) async {
    try {
      _ref.read(bookSearchProvider.notifier).search(query);
      await Future.delayed(const Duration(milliseconds: 800));
      final bState = _ref.read(bookSearchProvider);
      return bState.whenOrNull(data: (list) {
        return list
            .map((b) => SearchResult(
                  id: 'book_${b.id}',
                  title: b.title,
                  subtitle: b.authors.join(', '),
                  imageUrl: b.thumbnailUrl,
                  type: SearchCategory.books,
                ))
            .toList();
      }) ?? [];
    } catch (_) {
      return [];
    }
  }

  void setCategory(SearchCategory cat) {
    state = state.copyWith(category: cat);
  }

  void clear() {
    state = const SearchState();
  }
}

final globalSearchProvider =
    StateNotifierProvider<SearchNotifierGlobal, SearchState>(
        (ref) => SearchNotifierGlobal(ref));

// ─── SEARCH SCREEN ────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(globalSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.8),
              border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile, 12, AppSpacing.marginMobile, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.onSurface),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(Icons.search_rounded,
                                color: AppColors.onSurfaceVariant, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                style: AppTypography.bodyMd
                                    .copyWith(color: AppColors.onSurface),
                                decoration: InputDecoration(
                                  hintText:
                                      'Film, dizi, oyun, kitap ara...',
                                  hintStyle: AppTypography.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (v) {
                                  ref
                                      .read(globalSearchProvider.notifier)
                                      .search(v);
                                },
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  ref
                                      .read(globalSearchProvider.notifier)
                                      .clear();
                                },
                                icon: Icon(Icons.close_rounded,
                                    color: AppColors.onSurfaceVariant,
                                    size: 18),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category Filter
          if (searchState.query.isNotEmpty)
            _CategoryFilter(
              selected: searchState.category,
              onSelect: (cat) =>
                  ref.read(globalSearchProvider.notifier).setCategory(cat),
            ),

          // Content
          Expanded(
            child: searchState.query.isEmpty
                ? _EmptyState()
                : searchState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : searchState.results.isEmpty
                        ? _NoResults(query: searchState.query)
                        : _ResultsList(
                            results: _filteredResults(
                                searchState.results, searchState.category),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  List<SearchResult> _filteredResults(
      List<SearchResult> all, SearchCategory cat) {
    if (cat == SearchCategory.all) return all;
    return all.where((r) => r.type == cat).toList();
  }
}

// ─── CATEGORY FILTER ──────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final SearchCategory selected;
  final ValueChanged<SearchCategory> onSelect;

  const _CategoryFilter({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cats = [
      (SearchCategory.all, 'Tümü', Icons.apps_rounded),
      (SearchCategory.movies, 'Film', Icons.movie_rounded),
      (SearchCategory.series, 'Dizi', Icons.tv_rounded),
      (SearchCategory.games, 'Oyun', Icons.sports_esports_rounded),
      (SearchCategory.books, 'Kitap', Icons.menu_book_rounded),
    ];

    return Container(
      height: 48,
      color: AppColors.surfaceContainer.withValues(alpha: 0.4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile, vertical: 8),
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final (cat, label, icon) = cats[i];
          final isSelected = selected == cat;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 14,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Text(label,
                      style: AppTypography.labelCaps.copyWith(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── RESULTS LIST ─────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final List<SearchResult> results;
  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: results.length,
      itemBuilder: (ctx, i) => _ResultTile(result: results[i]),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final SearchResult result;
  const _ResultTile({required this.result});

  Color get _typeColor {
    switch (result.type) {
      case SearchCategory.movies:
        return const Color(0xFF6C63FF);
      case SearchCategory.series:
        return const Color(0xFF00B4D8);
      case SearchCategory.games:
        return const Color(0xFF2EC4B6);
      case SearchCategory.books:
        return const Color(0xFFE9C46A);
      default:
        return AppColors.primary;
    }
  }

  String get _typeLabel {
    switch (result.type) {
      case SearchCategory.movies:
        return 'FİLM';
      case SearchCategory.series:
        return 'DİZİ';
      case SearchCategory.games:
        return 'OYUN';
      case SearchCategory.books:
        return 'KİTAP';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          // Poster/Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusMd),
              bottomLeft: Radius.circular(AppSpacing.radiusMd),
            ),
            child: result.imageUrl != null
                ? Image.network(
                    result.imageUrl!,
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(color: _typeColor),
                  )
                : _Placeholder(color: _typeColor),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _typeColor,
                              letterSpacing: 0.5),
                        ),
                      ),
                      if (result.rating != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          result.rating!.toStringAsFixed(1),
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    result.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color color;
  const _Placeholder({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 90,
      color: color.withValues(alpha: 0.2),
      child: Icon(Icons.image_rounded, color: color.withValues(alpha: 0.5)),
    );
  }
}

// ─── EMPTY STATES ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 20),
          Text('Ne arıyorsun?',
              style: AppTypography.headlineLgMobile
                  .copyWith(color: AppColors.onSurface)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Film, dizi, oyun veya kitap adı yazarak arama yapabilirsin.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
          // Quick suggestions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: ['Breaking Bad', 'Elden Ring', 'Dune', 'Inception',
                'Witcher', 'Sapiens']
                  .map((s) => GestureDetector(
                        onTap: () {
                          // ignore: use_build_context_synchronously
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Text(s,
                              style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.onSurfaceVariant, size: 64),
          const SizedBox(height: 16),
          Text('"$query" için sonuç bulunamadı',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
