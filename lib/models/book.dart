// lib/models/book.dart
import 'package:flutter/foundation.dart';
class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedDate;
  final List<String> categories;
  final int? pageCount;
  final String? previewLink;
  final String? infoLink;
  final String? price;
  final String? currencyCode;
  final double? retailPrice;

  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.description,
    this.thumbnailUrl,
    this.publishedDate,
    this.categories = const [],
    this.pageCount,
    this.previewLink,
    this.infoLink,
    this.price,
    this.currencyCode,
    this.retailPrice,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final saleInfo = json['saleInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final retailPriceData = saleInfo['retailPrice'] as Map<String, dynamic>?;

    String? thumbnail = (imageLinks['extraLarge'] ??
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['small'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail']) as String?;

    if (thumbnail != null) {
      thumbnail = thumbnail.replaceAll('http://', 'https://');
      if (kIsWeb) {
        thumbnail = 'https://images.weserv.nl/?url=${Uri.encodeComponent(thumbnail)}';
      }
    }

    return Book(
      id: json['id'] as String,
      title: volumeInfo['title'] as String? ?? 'Bilinmiyor',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      description: volumeInfo['description'] as String?,
      thumbnailUrl: thumbnail,
      publishedDate: volumeInfo['publishedDate'] as String?,
      categories: List<String>.from(volumeInfo['categories'] ?? []),
      pageCount: volumeInfo['pageCount'] as int?,
      previewLink: volumeInfo['previewLink'] as String?,
      infoLink: volumeInfo['infoLink'] as String?,
      retailPrice: (retailPriceData?['amount'] as num?)?.toDouble(),
      currencyCode: retailPriceData?['currencyCode'] as String?,
      price: saleInfo['saleability'] == 'FOR_SALE'
          ? (retailPriceData != null
              ? '${retailPriceData['amount']} ${retailPriceData['currencyCode']}'
              : null)
          : null,
    );
  }

  String get authorsString => authors.join(', ');
}
