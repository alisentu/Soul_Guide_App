import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_series.dart';
import '../models/game.dart';
import '../models/book.dart';
import '../models/product.dart';
import '../services/tmdb_service.dart';
import '../services/rawg_service.dart';
import '../services/books_service.dart';
import '../services/trendyol_service.dart';
import 'user_provider.dart';

final tmdbServiceProvider = Provider<TmdbService>((ref) => TmdbService());
final rawgServiceProvider = Provider<RawgService>((ref) => RawgService());
final booksServiceProvider = Provider<BooksService>((ref) => BooksService());
final trendyolServiceProvider =
    Provider<TrendyolService>((ref) => TrendyolService());

// ─── MOCK FALLBACK DATA ────────────────────────────────────────────────────

List<MovieSeries> _mockMovies() => [
      const MovieSeries(
          id: 1,
          title: 'Interstellar',
          overview: 'Evrenin derinliklerinde umut arayışı.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.6,
          mediaType: 'movie',
          genreIds: [878]),
      const MovieSeries(
          id: 2,
          title: 'Inception',
          overview:
              'Rüya katmanlarında gerçeklik sınırlarını zorlayan bir yolculuk.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.8,
          mediaType: 'movie',
          genreIds: [28]),
      const MovieSeries(
          id: 3,
          title: 'The Dark Knight',
          overview: 'Gotham\'ın kaderini belirleyecek bir savaş.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 9.0,
          mediaType: 'movie',
          genreIds: [28]),
      const MovieSeries(
          id: 4,
          title: 'Dune: Part Two',
          overview: 'Paul Atreides\'in efsanevi yükselişi.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.5,
          mediaType: 'movie',
          genreIds: [878]),
      const MovieSeries(
          id: 5,
          title: 'Oppenheimer',
          overview: 'Tarihin en güçlü silahının hikayesi.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.4,
          mediaType: 'movie',
          genreIds: [18]),
      const MovieSeries(
          id: 6,
          title: 'Poor Things',
          overview: 'Yeniden doğan bir kadının keşif hikayesi.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 7.9,
          mediaType: 'movie',
          genreIds: [18]),
    ];

List<MovieSeries> _mockSeries() => [
      const MovieSeries(
          id: 101,
          title: 'Breaking Bad',
          overview: 'Sıradan bir öğretmenin dönüşüm hikayesi.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 9.5,
          mediaType: 'tv',
          genreIds: [80]),
      const MovieSeries(
          id: 102,
          title: 'Severance',
          overview: 'İş ve özel hayatın ayrıştığı distopik bir dünya.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.7,
          mediaType: 'tv',
          genreIds: [18]),
      const MovieSeries(
          id: 103,
          title: 'The Last of Us',
          overview: 'Kıyamet sonrası dünyada hayatta kalma mücadelesi.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.8,
          mediaType: 'tv',
          genreIds: [878]),
      const MovieSeries(
          id: 104,
          title: 'Dark',
          overview: 'Zaman yolculuğu ve aile sırları üzerine Alman yapımı.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.8,
          mediaType: 'tv',
          genreIds: [9648]),
      const MovieSeries(
          id: 105,
          title: 'Shogun',
          overview: 'Feodal Japonya\'da bir İngiliz denizcinin macerası.',
          posterPath: '',
          backdropPath: '',
          voteAverage: 8.9,
          mediaType: 'tv',
          genreIds: [18]),
    ];

List<Game> _mockGames() => [
      const Game(
          id: 1,
          name: 'Elden Ring',
          backgroundImage: null,
          rating: 4.8,
          genres: ['Action RPG', 'Souls-like']),
      const Game(
          id: 2,
          name: 'Baldur\'s Gate 3',
          backgroundImage: null,
          rating: 4.9,
          genres: ['RPG', 'Turn-based']),
      const Game(
          id: 3,
          name: 'Cyberpunk 2077',
          backgroundImage: null,
          rating: 4.4,
          genres: ['Action RPG', 'Open World']),
      const Game(
          id: 4,
          name: 'Hades II',
          backgroundImage: null,
          rating: 4.7,
          genres: ['Roguelike', 'Action']),
      const Game(
          id: 5,
          name: 'Hollow Knight',
          backgroundImage: null,
          rating: 4.6,
          genres: ['Metroidvania', 'Indie']),
      const Game(
          id: 6,
          name: 'Disco Elysium',
          backgroundImage: null,
          rating: 4.6,
          genres: ['RPG', 'Detective']),
    ];

List<Book> _mockBooks() => [
      const Book(
          id: 'b1',
          title: 'Dune',
          authors: ['Frank Herbert'],
          thumbnailUrl: 'https://images.weserv.nl/?url=https://covers.openlibrary.org/b/id/8314153-L.jpg',
          description: 'Çöl gezegeninde siyasi entrikalar ve kehanet.',
          infoLink: 'https://books.google.com.tr/books?id=bK5ZDwAAQBAJ',
          price: null),
      const Book(
          id: 'b2',
          title: 'Sapiens',
          authors: ['Yuval Noah Harari'],
          thumbnailUrl: 'https://images.weserv.nl/?url=https://covers.openlibrary.org/b/id/11100346-L.jpg',
          description: 'İnsan türünün kısa tarihi.',
          infoLink: 'https://books.google.com.tr/books?id=FegOCwAAQBAJ',
          price: null),
      const Book(
          id: 'b3',
          title: 'Şeker Portakalı',
          authors: ['José Mauro de Vasconcelos'],
          thumbnailUrl: 'https://images.weserv.nl/?url=https://covers.openlibrary.org/b/id/8447814-L.jpg',
          description: 'Küçük Zezé\'nin büyüleyici dünyası.',
          infoLink: 'https://books.google.com.tr/books?id=3T2GDwAAQBAJ',
          price: null),
      const Book(
          id: 'b4',
          title: 'Siddhartha',
          authors: ['Hermann Hesse'],
          thumbnailUrl: 'https://images.weserv.nl/?url=https://covers.openlibrary.org/b/id/8302094-L.jpg',
          description: 'Aydınlanma yolunda bir ruhun hikayesi.',
          infoLink: 'https://books.google.com.tr/books?id=p2-GDwAAQBAJ',
          price: null),
      const Book(
          id: 'b5',
          title: 'Savaş ve Barış',
          authors: ['Lev Tolstoy'],
          thumbnailUrl: 'https://images.weserv.nl/?url=https://covers.openlibrary.org/b/id/12836263-L.jpg',
          description: 'Napoleonik dönemde Rus toplumu.',
          infoLink: 'https://books.google.com.tr/books?id=h3-GDwAAQBAJ',
          price: null),
      const Book(
          id: 'b6',
          title: 'Suç ve Ceza',
          authors: ['Fyodor Dostoyevski'],
          thumbnailUrl: 'https://images.weserv.nl/?url=https://covers.openlibrary.org/b/id/8226065-L.jpg',
          description: 'Vicdan ve pişmanlığın psikolojik derinliği.',
          infoLink: 'https://books.google.com.tr/books?id=kX-GDwAAQBAJ',
          price: null),
    ];

// ─── HELPER: safe API call with fallback ─────────────────────────────────

Future<T> _safeCall<T>(Future<T> Function() apiCall, T fallback) async {
  try {
    return await apiCall();
  } catch (e) {
    final msg = e.toString().toLowerCase();
    // 429, rate limit, quota
    if (msg.contains('429') ||
        msg.contains('rate') ||
        msg.contains('quota') ||
        msg.contains('limit')) {
      return fallback;
    }
    // Network or any other error → also fallback in production
    return fallback;
  }
}

// ─── MOVIES ───────────────────────────────────────────────────────────────

final moviesProvider = FutureProvider<List<MovieSeries>>((ref) async {
  final tmdb = ref.watch(tmdbServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  final profile = ref.watch(userProfileProvider);

  return _safeCall(() async {
    // Önce movieGenres (kesin tercihler), yoksa genel tags kullan
    final movieTags = profile?.movieGenres.isNotEmpty == true
        ? profile!.movieGenres
        : (profile?.interestTags ?? []);

    if (movieTags.isNotEmpty) {
      final genreIds = gemini.tagsToTmdbGenreIds(movieTags);
      if (genreIds.isNotEmpty) {
        final page1 = Random().nextInt(2) + 1; // 1-2
        final page2 = Random().nextInt(2) + 3; // 3-4
        final futures = await Future.wait([
          tmdb.getRecommendations(
              genreIds: genreIds, type: 'movie', page: page1),
          tmdb.getRecommendations(
              genreIds: genreIds, type: 'movie', page: page2),
        ]);
        final results = [...futures[0], ...futures[1]];
        results.shuffle();
        if (results.isNotEmpty) {
          final uniqueResults =
              {for (var item in results) item.id: item}.values.toList();
          return uniqueResults;
        }
      }
    }
    final pop =
        await tmdb.getPopular(type: 'movie', page: Random().nextInt(3) + 1);
    pop.shuffle();
    return pop;
  }, _mockMovies());
});

final seriesProvider = FutureProvider<List<MovieSeries>>((ref) async {
  final tmdb = ref.watch(tmdbServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  final profile = ref.watch(userProfileProvider);

  return _safeCall(() async {
    // Önce movieGenres, yoksa genel tags
    final movieTags = profile?.movieGenres.isNotEmpty == true
        ? profile!.movieGenres
        : (profile?.interestTags ?? []);

    if (movieTags.isNotEmpty) {
      final genreIds = gemini.tagsToTmdbGenreIds(movieTags);
      if (genreIds.isNotEmpty) {
        final page1 = Random().nextInt(2) + 1;
        final page2 = Random().nextInt(2) + 3;
        final futures = await Future.wait([
          tmdb.getRecommendations(genreIds: genreIds, type: 'tv', page: page1),
          tmdb.getRecommendations(genreIds: genreIds, type: 'tv', page: page2),
        ]);
        final results = [...futures[0], ...futures[1]];
        results.shuffle();
        if (results.isNotEmpty) {
          final uniqueResults =
              {for (var item in results) item.id: item}.values.toList();
          return uniqueResults;
        }
      }
    }
    final pop =
        await tmdb.getPopular(type: 'tv', page: Random().nextInt(3) + 1);
    pop.shuffle();
    return pop;
  }, _mockSeries());
});

final trendingProvider = FutureProvider<List<MovieSeries>>((ref) async {
  final tmdb = ref.watch(tmdbServiceProvider);
  return _safeCall(() => tmdb.getTrending(), _mockMovies());
});

// ─── SEARCH ───────────────────────────────────────────────────────────────

final movieSearchProvider = StateNotifierProvider<
        SearchNotifier<MovieSeries>, AsyncValue<List<MovieSeries>>>(
    (ref) => SearchNotifier(
          (query) async {
            try {
              return await ref.read(tmdbServiceProvider).search(query);
            } catch (_) {
              return _mockMovies()
                  .where((m) =>
                      m.title.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            }
          },
        ));

// ─── GAMES ────────────────────────────────────────────────────────────────

final gamesProvider = FutureProvider<List<Game>>((ref) async {
  final rawg = ref.watch(rawgServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  final profile = ref.watch(userProfileProvider);

  return _safeCall(() async {
    // Önce gameGenres, yoksa genel tags
    final gameTags = profile?.gameGenres.isNotEmpty == true
        ? profile!.gameGenres
        : (profile?.interestTags ?? []);

    if (gameTags.isNotEmpty) {
      final genres = gemini.tagsToMultipleGameGenres(gameTags);
      if (genres.isNotEmpty) {
        final genreQuery = genres.join(','); // RAWG destekliyor: "action,rpg"
        final page1 = Random().nextInt(2) + 1;
        final page2 = Random().nextInt(2) + 3;
        final futures = await Future.wait([
          rawg.getRecommendations(genre: genreQuery, page: page1),
          rawg.getRecommendations(genre: genreQuery, page: page2),
        ]);
        final results = [...futures[0], ...futures[1]];
        results.shuffle();
        if (results.isNotEmpty) {
          final uniqueResults =
              {for (var item in results) item.id: item}.values.toList();
          return uniqueResults;
        }
      }
    }
    final pop = await rawg.getPopular(page: Random().nextInt(3) + 1);
    pop.shuffle();
    return pop;
  }, _mockGames());
});

final gameSearchProvider =
    StateNotifierProvider<SearchNotifier<Game>, AsyncValue<List<Game>>>((ref) =>
        SearchNotifier(
          (query) async {
            try {
              return await ref.read(rawgServiceProvider).search(query);
            } catch (_) {
              return _mockGames()
                  .where(
                      (g) => g.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            }
          },
        ));

// ─── BOOKS ────────────────────────────────────────────────────────────────

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final books = ref.watch(booksServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  final profile = ref.watch(userProfileProvider);

  return _safeCall(() async {
    // Önce bookTopics, yoksa genel tags
    final bookTags = profile?.bookTopics.isNotEmpty == true
        ? profile!.bookTopics
        : (profile?.interestTags ?? []);

    final subject = gemini.tagsToBookSubjects(bookTags);

    // Books API'den max 40 tane farklı start index ile çekelim
    final randomStart = Random().nextInt(20);
    final results = await books.getRecommendationsMixed(
        subject: subject, maxResults: 40, startIndex: randomStart);

    if (results.isNotEmpty) {
      results.shuffle();
      final uniqueResults =
          {for (var item in results) item.id: item}.values.toList();

      // Görsel veri olanları filtrele (thumbnailUrl'si olan kitaplar)
      final withVisuals = uniqueResults
          .where((book) =>
              book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty)
          .toList();

      return withVisuals.isNotEmpty ? withVisuals : uniqueResults;
    }

    final fb = await books.getRecommendationsMixed(
        subject: 'fiction', maxResults: 40, startIndex: randomStart);
    fb.shuffle();

    // Görsel veri olanları filtrele
    final withVisuals = fb
        .where((book) =>
            book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty)
        .toList();

    return withVisuals.isNotEmpty ? withVisuals : fb;
  }, _mockBooks());
});

final bookSearchProvider =
    StateNotifierProvider<SearchNotifier<Book>, AsyncValue<List<Book>>>(
        (ref) => SearchNotifier(
              (query) async {
                try {
                  return await ref.read(booksServiceProvider).search(query);
                } catch (_) {
                  return _mockBooks()
                      .where((b) =>
                          b.title.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              },
            ));

// ─── PRODUCTS ─────────────────────────────────────────────────────────────

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final trendyol = ref.watch(trendyolServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  final profile = ref.watch(userProfileProvider);

  try {
    final tags = profile?.interestTags ?? [];
    final fallbackQuery = tags.isNotEmpty ? tags.first : 'hediye';

    // Profil tabanlı akıllı kategori önerisi
    final category = await gemini.generateShoppingCategory(
        tags, profile?.age, profile?.zodiacSign);

    if (category.isEmpty) {
      return await trendyol.searchProducts(fallbackQuery);
    }

    // Doğrudan Trendyol'dan sonuç al
    final results = await trendyol.searchProducts(category);

    if (results.isNotEmpty) {
      results.shuffle();
      return results.take(15).toList();
    }

    // Sonuç yoksa fallback olarak genel arama
    return await trendyol.searchProducts(fallbackQuery);
  } catch (e) {
    // Hata durumunda güvenli bir arama dene
    try {
      return await trendyol.searchProducts('trend');
    } catch (_) {
      return [];
    }
  }
});
final dailyPickMovieProvider = FutureProvider<MovieSeries?>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  if (movies.isEmpty) return null;
  final now = DateTime.now();
  return movies[now.day % movies.length];
});

final dailyPickGameProvider = FutureProvider<Game?>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  if (games.isEmpty) return null;
  final now = DateTime.now();
  return games[(now.day + now.weekday) % games.length];
});

final dailyPickBookProvider = FutureProvider<Book?>((ref) async {
  final books = await ref.watch(booksProvider.future);
  if (books.isEmpty) return null;
  final now = DateTime.now();
  return books[now.day % books.length];
});

// ─── GENERIC SEARCH NOTIFIER ──────────────────────────────────────────────

class SearchNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  final Future<List<T>> Function(String query) _searchFn;
  String _lastQuery = '';

  SearchNotifier(this._searchFn) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query == _lastQuery) return;
    _lastQuery = query;
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final results = await _searchFn(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    _lastQuery = '';
    state = const AsyncValue.data([]);
  }
}
