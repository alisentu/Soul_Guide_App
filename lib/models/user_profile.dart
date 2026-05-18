// lib/models/user_profile.dart
class UserProfile {
  final String id;
  final String name;
  final int? age;
  final String? zodiacSign;
  final List<String> focusAreas;
  final List<String> interestTags;
  final String? archetypeLabel;
  final String? archetypeSummary;
  final int completedTests;
  final int streak;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  // Gemini'den gelen içerik tercihleri
  final List<String> movieGenres;    // örn: ['korku', 'gerilim']
  final List<String> gameGenres;     // örn: ['strateji', 'rpg']
  final List<String> bookTopics;     // örn: ['psikoloji', 'gerilim']

  const UserProfile({
    required this.id,
    required this.name,
    this.age,
    this.zodiacSign,
    this.focusAreas = const [],
    this.interestTags = const [],
    this.archetypeLabel,
    this.archetypeSummary,
    this.completedTests = 0,
    this.streak = 0,
    required this.createdAt,
    this.lastActiveAt,
    this.movieGenres = const [],
    this.gameGenres = const [],
    this.bookTopics = const [],
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? zodiacSign,
    List<String>? focusAreas,
    List<String>? interestTags,
    String? archetypeLabel,
    String? archetypeSummary,
    int? completedTests,
    int? streak,
    DateTime? lastActiveAt,
    List<String>? movieGenres,
    List<String>? gameGenres,
    List<String>? bookTopics,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      focusAreas: focusAreas ?? this.focusAreas,
      interestTags: interestTags ?? this.interestTags,
      archetypeLabel: archetypeLabel ?? this.archetypeLabel,
      archetypeSummary: archetypeSummary ?? this.archetypeSummary,
      completedTests: completedTests ?? this.completedTests,
      streak: streak ?? this.streak,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      movieGenres: movieGenres ?? this.movieGenres,
      gameGenres: gameGenres ?? this.gameGenres,
      bookTopics: bookTopics ?? this.bookTopics,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'zodiacSign': zodiacSign,
        'focusAreas': focusAreas,
        'interestTags': interestTags,
        'archetypeLabel': archetypeLabel,
        'archetypeSummary': archetypeSummary,
        'completedTests': completedTests,
        'streak': streak,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'movieGenres': movieGenres,
        'gameGenres': gameGenres,
        'bookTopics': bookTopics,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        age: json['age'] as int?,
        zodiacSign: json['zodiacSign'] as String?,
        focusAreas: List<String>.from(json['focusAreas'] ?? []),
        interestTags: List<String>.from(json['interestTags'] ?? []),
        archetypeLabel: json['archetypeLabel'] as String?,
        archetypeSummary: json['archetypeSummary'] as String?,
        completedTests: json['completedTests'] as int? ?? 0,
        streak: json['streak'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastActiveAt: json['lastActiveAt'] != null
            ? DateTime.parse(json['lastActiveAt'] as String)
            : null,
        movieGenres: List<String>.from(json['movieGenres'] ?? []),
        gameGenres: List<String>.from(json['gameGenres'] ?? []),
        bookTopics: List<String>.from(json['bookTopics'] ?? []),
      );

  static UserProfile empty() => UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        createdAt: DateTime.now(),
      );
}
