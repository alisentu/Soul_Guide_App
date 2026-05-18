// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final String category;
  final List<String> tags;
  final String? brand;
  final double? rating;
  final String? purchaseUrl;
  final String? source; // 'fakestore', 'trendyol', etc.

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.currency = '₺',
    required this.category,
    this.tags = const [],
    this.brand,
    this.rating,
    this.purchaseUrl,
    this.source,
  });

  String get formattedPrice => '$currency${price.toStringAsFixed(0)}';

  factory Product.fromFakeStore(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['title'] ?? 'Ürün',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? 'https://via.placeholder.com/400',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: '\$', // Fake Store dolar bazlıdır
      category: json['category'] ?? 'alışveriş',
      brand: 'FakeStore',
      rating: json['rating'] != null
          ? (json['rating']['rate'] as num?)?.toDouble()
          : null,
      purchaseUrl: null, // Fake Store link vermez
      tags: [],
      source: 'fakestore',
    );
  }
}

// lib/models/analysis_data.dart
class RadarDimension {
  final String label;
  final double value; // 0.0 - 1.0
  final String color;

  const RadarDimension({
    required this.label,
    required this.value,
    required this.color,
  });
}

class AnalysisData {
  final List<RadarDimension> dimensions;
  final String insight;
  final String quickTip;
  final String? archetypeLabel;
  final List<String> insightTags;
  final DateTime generatedAt;

  const AnalysisData({
    required this.dimensions,
    required this.insight,
    required this.quickTip,
    this.archetypeLabel,
    this.insightTags = const [],
    required this.generatedAt,
  });

  factory AnalysisData.empty() => AnalysisData(
        dimensions: [
          const RadarDimension(label: 'Odak', value: 0.0, color: '#E5EEFF'),
          const RadarDimension(
              label: 'Yaratıcılık', value: 0.0, color: '#D2BFE7'),
          const RadarDimension(label: 'Empati', value: 0.0, color: '#CEF7DE'),
          const RadarDimension(
              label: 'Dayanıklılık', value: 0.0, color: '#A9C9F3'),
          const RadarDimension(label: 'Huzur', value: 0.0, color: '#D2BFE7'),
        ],
        insight: '',
        quickTip: '',
        generatedAt: DateTime(2024),
      );

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    final dims = (json['dimensions'] as List<dynamic>?)?.map((d) {
          final m = d as Map<String, dynamic>;
          return RadarDimension(
            label: m['label'] as String,
            value: (m['value'] as num).toDouble() / 100,
            color: m['color'] as String? ?? '#E5EEFF',
          );
        }).toList() ??
        [];

    return AnalysisData(
      dimensions: dims.isNotEmpty
          ? dims
          : [
              RadarDimension(
                  label: 'Odak',
                  value: (json['focus'] as num? ?? 50) / 100,
                  color: '#E5EEFF'),
              RadarDimension(
                  label: 'Yaratıcılık',
                  value: (json['creativity'] as num? ?? 50) / 100,
                  color: '#D2BFE7'),
              RadarDimension(
                  label: 'Empati',
                  value: (json['empathy'] as num? ?? 50) / 100,
                  color: '#CEF7DE'),
              RadarDimension(
                  label: 'Dayanıklılık',
                  value: (json['resilience'] as num? ?? 50) / 100,
                  color: '#A9C9F3'),
              RadarDimension(
                  label: 'Huzur',
                  value: (json['calm'] as num? ?? 50) / 100,
                  color: '#D2BFE7'),
            ],
      insight: json['insight'] as String? ?? '',
      quickTip: json['quickTip'] as String? ?? '',
      archetypeLabel: json['archetypeLabel'] as String?,
      insightTags: List<String>.from(json['insightTags'] ?? []),
      generatedAt: DateTime.now(),
    );
  }
}
