import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserProfileNotifier(storage);
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final StorageService _storage;

  UserProfileNotifier(this._storage) : super(null) {
    _load();
  }

  void _load() {
    state = _storage.getUserProfile();
  }

  Future<void> createProfile({
    required String name,
    int? age,
    String? zodiacSign,
    List<String> focusAreas = const [],
  }) async {
    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      zodiacSign: zodiacSign,
      focusAreas: focusAreas,
      createdAt: DateTime.now(),
    );
    state = profile;
    await _storage.saveUserProfile(profile);
  }

  Future<void> updateWithAiProfile(Map<String, dynamic> aiProfile) async {
    if (state == null) return;

    // Mevcut tag'lara yeni tag'ları EKLE (üzerine yazma)
    final existingTags = state!.interestTags;
    final newTags = List<String>.from(aiProfile['tags'] ?? []);
    final mergedTags = {...existingTags, ...newTags}.toList();

    // İçerik tercihleri (her test sonrasında güncellenir)
    final movieGenres = List<String>.from(aiProfile['movieGenres'] ?? []);
    final gameGenres = List<String>.from(aiProfile['gameGenres'] ?? []);
    final bookTopics = List<String>.from(aiProfile['bookTopics'] ?? []);

    final updated = state!.copyWith(
      interestTags: mergedTags,
      archetypeLabel: aiProfile['archetypeLabel'] as String?,
      archetypeSummary: aiProfile['archetypeSummary'] as String?,
      movieGenres: movieGenres.isNotEmpty ? movieGenres : state!.movieGenres,
      gameGenres: gameGenres.isNotEmpty ? gameGenres : state!.gameGenres,
      bookTopics: bookTopics.isNotEmpty ? bookTopics : state!.bookTopics,
    );
    state = updated;
    await _storage.saveUserProfile(updated);
  }

  Future<void> incrementCompletedTests() async {
    if (state == null) return;
    final updated = state!.copyWith(
      completedTests: state!.completedTests + 1,
      lastActiveAt: DateTime.now(),
    );
    state = updated;
    await _storage.saveUserProfile(updated);
  }

  Future<void> updateStreak() async {
    if (state == null) return;
    final last = state!.lastActiveAt;
    final now = DateTime.now();
    int newStreak = state!.streak;

    if (last != null) {
      final diff = now.difference(last).inDays;
      if (diff == 1) {
        newStreak++;
      } else if (diff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final updated = state!.copyWith(
      streak: newStreak,
      lastActiveAt: now,
    );
    state = updated;
    await _storage.saveUserProfile(updated);
  }

  Future<void> updateTags(List<String> newTags) async {
    if (state == null) return;
    final allTags = {...state!.interestTags, ...newTags}.toList();
    final updated = state!.copyWith(interestTags: allTags);
    state = updated;
    await _storage.saveUserProfile(updated);
  }
}
