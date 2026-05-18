// lib/models/game.dart
class Game {
  final int id;
  final String name;
  final String? backgroundImage;
  final double? rating;
  final List<String> genres;
  final List<String> platforms;
  final String? released;
  final String? description;
  final String? steamAppId;
  final String? price;
  final String? storeUrl;

  const Game({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.rating,
    this.genres = const [],
    this.platforms = const [],
    this.released,
    this.description,
    this.steamAppId,
    this.price,
    this.storeUrl,
  });

  factory Game.fromRawgJson(Map<String, dynamic> json) {
    final genresList = (json['genres'] as List<dynamic>?)
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String)
            .toList() ??
        [];

    final platformsList = (json['platforms'] as List<dynamic>?)
            ?.map((p) =>
                ((p as Map<String, dynamic>)['platform'] as Map<String, dynamic>)['name'] as String)
            .toList() ??
        [];

    return Game(
      id: json['id'] as int,
      name: json['name'] as String,
      backgroundImage: json['background_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      genres: genresList,
      platforms: platformsList,
      released: json['released'] as String?,
      description: json['description_raw'] as String?,
    );
  }

  Game copyWith({String? price, String? storeUrl, String? steamAppId}) {
    return Game(
      id: id,
      name: name,
      backgroundImage: backgroundImage,
      rating: rating,
      genres: genres,
      platforms: platforms,
      released: released,
      description: description,
      steamAppId: steamAppId ?? this.steamAppId,
      price: price ?? this.price,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }
}
