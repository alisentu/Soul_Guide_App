// lib/models/movie_series.dart
class WatchProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final String? link;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    this.link,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) => WatchProvider(
        providerId: json['provider_id'] as int,
        providerName: json['provider_name'] as String,
        logoPath: json['logo_path'] as String?,
      );

  String get logoUrl => logoPath != null
      ? 'https://image.tmdb.org/t/p/w45$logoPath'
      : '';
}

class MovieSeries {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final List<int> genreIds;
  final double voteAverage;
  final String? releaseDate;
  final String mediaType; // 'movie' or 'tv'
  final List<WatchProvider> watchProviders;

  const MovieSeries({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    this.genreIds = const [],
    required this.voteAverage,
    this.releaseDate,
    required this.mediaType,
    this.watchProviders = const [],
  });

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  factory MovieSeries.fromJson(Map<String, dynamic> json, {String type = 'movie'}) {
    return MovieSeries(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      mediaType: json['media_type'] as String? ?? type,
    );
  }

  MovieSeries copyWithProviders(List<WatchProvider> providers) {
    return MovieSeries(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      genreIds: genreIds,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      mediaType: mediaType,
      watchProviders: providers,
    );
  }
}
