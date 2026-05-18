import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book.dart';

class BooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';
  late final Dio _dio;
  late final String _apiKey;

  BooksService() {
    _apiKey = dotenv.env['BOOKS_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// Profil tabanlı kitap önerileri
  Future<List<Book>> getRecommendations({
    String subject = 'fiction',
    int maxResults = 20,
    int startIndex = 0,
  }) async {
    final response = await _dio.get('/volumes', queryParameters: {
      'q': 'subject:$subject',
      'key': _apiKey,
      'maxResults': maxResults,
      'startIndex': startIndex,
      'orderBy': 'relevance',
      'langRestrict': 'tr',
      'printType': 'books',
    });

    final items = response.data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .where((b) => b.title.isNotEmpty)
        .toList();
  }

  /// İngilizce kitaplar da dahil
  Future<List<Book>> getRecommendationsMixed({
    String subject = 'fiction',
    int maxResults = 20,
    int startIndex = 0,
  }) async {
    final response = await _dio.get('/volumes', queryParameters: {
      'q': 'subject:$subject',
      'key': _apiKey,
      'maxResults': maxResults,
      'startIndex': startIndex,
      'orderBy': 'relevance',
      'printType': 'books',
    });

    final items = response.data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .where((b) => b.title.isNotEmpty)
        .toList();
  }

  /// Kitap arama
  Future<List<Book>> search(String query, {int maxResults = 20}) async {
    final response = await _dio.get('/volumes', queryParameters: {
      'q': query,
      'key': _apiKey,
      'maxResults': maxResults,
      'orderBy': 'relevance',
      'printType': 'books',
    });

    final items = response.data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .where((b) => b.title.isNotEmpty)
        .toList();
  }

  /// Kitap detayı
  Future<Book> getDetails(String id) async {
    final response = await _dio.get('/volumes/$id', queryParameters: {
      'key': _apiKey,
    });
    return Book.fromJson(response.data as Map<String, dynamic>);
  }
}
