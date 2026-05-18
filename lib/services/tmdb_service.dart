import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie_series.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  late final Dio _dio;
  late final String _apiKey;

  TmdbService() {
    _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      queryParameters: {
        'api_key': _apiKey,
        'language': 'tr-TR',
        'region': 'TR',
      },
    ));
  }

  /// Profil tabanlı film/dizi önerileri
  Future<List<MovieSeries>> getRecommendations({
    List<int> genreIds = const [],
    String type = 'movie',
    int page = 1,
  }) async {
    final endpoint = type == 'tv' ? '/discover/tv' : '/discover/movie';
    final params = {
      'sort_by': 'popularity.desc',
      'vote_count.gte': 100,
      'page': page,
    };
    if (genreIds.isNotEmpty) {
      params['with_genres'] = genreIds.join(',');
    }

    final response = await _dio.get(endpoint, queryParameters: params);
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => MovieSeries.fromJson(e as Map<String, dynamic>, type: type))
        .toList();
  }

  /// Popüler filmler (fallback)
  Future<List<MovieSeries>> getPopular({String type = 'movie', int page = 1}) async {
    final endpoint = type == 'tv' ? '/tv/popular' : '/movie/popular';
    final response = await _dio.get(endpoint, queryParameters: {'page': page});
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => MovieSeries.fromJson(e as Map<String, dynamic>, type: type))
        .toList();
  }

  /// İzleme platformlarını getir
  Future<List<WatchProvider>> getWatchProviders(int id, {String type = 'movie'}) async {
    try {
      final endpoint = type == 'tv'
          ? '/tv/$id/watch/providers'
          : '/movie/$id/watch/providers';
      final response = await _dio.get(endpoint);
      final results = response.data['results'] as Map<String, dynamic>?;

      // TR veya US sırasıyla dene
      final regionData = results?['TR'] ?? results?['US'];
      if (regionData == null) return [];

      final link = regionData['link'] as String?;
      final flatrate = regionData['flatrate'] as List<dynamic>? ?? [];
      final rent = regionData['rent'] as List<dynamic>? ?? [];
      final buy = regionData['buy'] as List<dynamic>? ?? [];

      final allProviders = [...flatrate, ...rent, ...buy];
      return allProviders
          .take(5)
          .map((p) {
            final provider = WatchProvider.fromJson(p as Map<String, dynamic>);
            return WatchProvider(
              providerId: provider.providerId,
              providerName: provider.providerName,
              logoPath: provider.logoPath,
              link: link,
            );
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Global arama (film + dizi)
  Future<List<MovieSeries>> search(String query, {int page = 1}) async {
    final response = await _dio.get(
      '/search/multi',
      queryParameters: {'query': query, 'page': page},
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .where((e) =>
            (e as Map<String, dynamic>)['media_type'] == 'movie' ||
            e['media_type'] == 'tv')
        .map((e) => MovieSeries.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Film/dizi detayı
  Future<MovieSeries> getDetails(int id, {String type = 'movie'}) async {
    final endpoint = type == 'tv' ? '/tv/$id' : '/movie/$id';
    final response = await _dio.get(endpoint);
    final item = MovieSeries.fromJson(
        response.data as Map<String, dynamic>, type: type);
    final providers = await getWatchProviders(id, type: type);
    return item.copyWithProviders(providers);
  }

  /// Trending içerikler
  Future<List<MovieSeries>> getTrending({String timeWindow = 'week'}) async {
    final response = await _dio.get('/trending/all/$timeWindow');
    final results = response.data['results'] as List<dynamic>;
    return results
        .where((e) =>
            (e as Map<String, dynamic>)['media_type'] == 'movie' ||
            e['media_type'] == 'tv')
        .take(10)
        .map((e) => MovieSeries.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
