import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/game.dart';

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';
  late final String _apiKey;
  late final Dio _dio;

  RawgService() {
    _apiKey = dotenv.env['RAWG_API_KEY'] ?? 'free';
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Map<String, dynamic> get _baseParams => {
    if (_apiKey != 'free') 'key': _apiKey,
    'page_size': 20,
  };

  /// Profil tabanlı oyun önerileri
  Future<List<Game>> getRecommendations({
    String? genre,
    int page = 1,
  }) async {
    final params = {
      ..._baseParams,
      'page': page,
      'ordering': '-added', // Popülerlik odaklı sıralama (çok daha çeşitli oyunlar getirir)
      'metacritic': '50,100',
    };
    if (genre != null && genre.isNotEmpty) {
      params['genres'] = genre;
    }

    final response = await _dio.get('/games', queryParameters: params);
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => Game.fromRawgJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Popüler oyunlar (fallback)
  Future<List<Game>> getPopular({int page = 1}) async {
    final params = {
      ..._baseParams,
      'page': page,
      'ordering': '-added',
      'metacritic': '60,100',
    };

    final response = await _dio.get('/games', queryParameters: params);
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => Game.fromRawgJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Oyun arama
  Future<List<Game>> search(String query, {int page = 1}) async {
    final params = {
      ..._baseParams,
      'search': query,
      'page': page,
    };

    final response = await _dio.get('/games', queryParameters: params);
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => Game.fromRawgJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Oyun detayı
  Future<Game> getDetails(int id) async {
    final response = await _dio.get('/games/$id', queryParameters: _baseParams);
    return Game.fromRawgJson(response.data as Map<String, dynamic>);
  }
}
