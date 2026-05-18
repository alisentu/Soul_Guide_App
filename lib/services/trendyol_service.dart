import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import '../models/product.dart';

final trendyolServiceProvider = Provider<TrendyolService>((ref) {
  return TrendyolService();
});

class TrendyolService {
  static const String _baseUrl = 'https://www.trendyol.com';
  late final Dio _dio;

  TrendyolService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Sec-Ch-Ua': '"Chromium";v="122", "Google Chrome";v="122"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Upgrade-Insecure-Requests': '1',
      },
    ));
  }

  Future<String> _fetchHtml(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      if (kIsWeb) {
        String urlString = '$_baseUrl$path';
        if (queryParameters != null && queryParameters.isNotEmpty) {
          final uri = Uri(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())));
          urlString += '?${uri.query}';
        }
        
        final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(urlString)}';
        final proxyDio = Dio(BaseOptions(headers: _dio.options.headers));
        final response = await proxyDio.get(proxyUrl);
        
        if (response.statusCode == 200) {
          return response.data as String;
        }
      } else {
        final response = await _dio.get(path, queryParameters: queryParameters);
        if (response.statusCode == 200) {
          return response.data as String;
        }
      }
    } catch (e) {
      debugPrint('Trendyol Fetch Error: $e');
    }
    return '';
  }

  Future<List<Product>> getTrendingProducts({String? category}) async {
    try {
      final query = category != null && category.isNotEmpty ? {'q': category} : {'q': 'trend'};
      final html = await _fetchHtml('/sr', queryParameters: query);
      if (html.isNotEmpty) {
        return _parseProductsFromHtml(html);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final html = await _fetchHtml('/sr', queryParameters: {'q': query});
      if (html.isNotEmpty) {
        final results = _parseProductsFromHtml(html);
        if (results.isNotEmpty) return results;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<Product> _parseProductsFromHtml(String htmlString) {
    final products = <Product>[];

    // YÖNTEM 1: JSON State Parsing (En güvenilir yöntem)
    try {
      final scriptRegex = RegExp(r'window\.__SEARCH_APP_INITIAL_STATE__\s*=\s*(\{.*?\});', dotAll: true);
      final match = scriptRegex.firstMatch(htmlString);

      if (match != null && match.groupCount >= 1) {
        final jsonString = match.group(1)!;
        final jsonData = jsonDecode(jsonString);
        final productsList = jsonData['products'] ?? [];
        
        for (var item in productsList) {
          final String title = item['name'] ?? 'Ürün';
          final String brand = item['brand']?['name'] ?? 'Trendyol';
          final double price = (item['price']?['sellingPrice'] as num?)?.toDouble() ?? 0.0;
          final String id = item['id']?.toString() ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
          final String productUrl = item['url'] ?? '';
          
          String imageUrl = '';
          if (item['images'] != null && (item['images'] as List).isNotEmpty) {
            imageUrl = 'https://cdn.dsmcdn.com/${item['images'][0]}';
          }

          if (title != 'Ürün' && price > 0) {
            products.add(Product(
              id: id,
              name: '$brand $title',
              price: price,
              description: 'Trendyol\'dan - $price TL',
              imageUrl: imageUrl,
              category: 'shopping',
              rating: (item['ratingScore']?['averageRating'] as num?)?.toDouble() ?? 4.0,
              source: 'trendyol',
              brand: brand,
              purchaseUrl: productUrl.isNotEmpty
                  ? (productUrl.startsWith('http') ? productUrl : 'https://www.trendyol.com$productUrl')
                  : null,
            ));
          }
        }
        
        if (products.isNotEmpty) {
          return products;
        }
      }
    } catch (e) {
      debugPrint('Trendyol JSON Parse Error: $e');
    }

    // YÖNTEM 2: DOM Parsing
    try {
      final document = html_parser.parse(htmlString);
      final productElements = document.querySelectorAll('.p-card-wrppr, [data-testid="productCard"]');

      for (var element in productElements) {
        try {
          final brandElement = element.querySelector('.prdct-desc-cntnr-ttl');
          final titleElement = element.querySelector('.prdct-desc-cntnr-name');
          
          final brandText = brandElement?.text.trim() ?? '';
          final titleText = titleElement?.text.trim() ?? 'Ürün';
          final fullTitle = brandText.isNotEmpty ? '$brandText $titleText' : titleText;

          final priceElement = element.querySelector('.prc-box-dscntd');
          final priceText = priceElement?.text.trim() ?? '0 TL';

          final linkElement = element.querySelector('a');
          final productUrl = linkElement?.attributes['href'] ?? '';
          final productId = _extractProductId(productUrl);

          final imageElement = element.querySelector('.p-card-img, img');
          final imageUrl = imageElement?.attributes['src'] ?? '';

          final product = Product(
            id: productId,
            name: fullTitle,
            price: double.tryParse(priceText
                    .replaceAll(RegExp(r'[^0-9,.]'), '')
                    .replaceAll(',', '.')) ?? 0.0,
            description: 'Trendyol\'dan - $priceText',
            imageUrl: imageUrl,
            category: 'shopping',
            rating: 4.0 + (productId.hashCode % 100) / 100,
            source: 'trendyol',
            brand: brandText.isNotEmpty ? brandText : 'Trendyol',
            purchaseUrl: productUrl.isNotEmpty
                ? (productUrl.startsWith('http') ? productUrl : 'https://www.trendyol.com$productUrl')
                : null,
          );

          if (product.name != 'Ürün' && product.imageUrl.isNotEmpty) {
            products.add(product);
          }
        } catch (e) {
          continue;
        }
      }

      if (products.isEmpty) {
        products.addAll(_parseAlternativeFormat(document));
      }

      return products;
    } catch (e) {
      return [];
    }
  }

  List<Product> _parseAlternativeFormat(Document document) {
    final products = <Product>[];
    try {
      final productElements = document.querySelectorAll(
          '.productCardImage, .productCard, [class*="product"], .product-card-container');

      for (var element in productElements.take(10)) {
        try {
          final title = element
                  .querySelector('h3, [class*="title"], .productTitle, span[title]')
                  ?.text
                  .trim() ??
              'Ürün';
          final priceText =
              element.querySelector('[class*="price"], .prc-box-dscntd')?.text.trim() ?? '0 TL';
          final imageUrl = element.querySelector('img')?.attributes['src'] ?? '';

          if (title.isNotEmpty && title != 'Ürün' && imageUrl.isNotEmpty) {
            final product = Product(
              id: 'trendyol_${DateTime.now().millisecondsSinceEpoch}_${products.length}',
              name: title,
              price: double.tryParse(priceText
                      .replaceAll(RegExp(r'[^0-9,.]'), '')
                      .replaceAll(',', '.')) ??
                  0.0,
              description: 'Trendyol\'dan - $priceText',
              imageUrl: imageUrl,
              category: 'shopping',
              rating: 4.0,
              source: 'trendyol',
              brand: 'Trendyol',
            );
            products.add(product);
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Sessiz hata
    }
    return products;
  }

  String _extractProductId(String url) {
    try {
      final match = RegExp(r'p-(\d+)').firstMatch(url);
      return match?.group(1) ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
