import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/quiz_question.dart';

class StorageService {
  static const String _profileKey = 'user_profile';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _sessionsKey = 'quiz_sessions';
  static const String _answersKey = 'all_answers';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) throw StateError('StorageService not initialized');
    return _prefs!;
  }

  // === ONBOARDING ===
  bool get isOnboardingComplete => prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingComplete() async {
    await prefs.setBool(_onboardingKey, true);
  }

  // === USER PROFILE ===
  UserProfile? getUserProfile() {
    final json = prefs.getString(_profileKey);
    if (json == null) return null;
    return UserProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // === QUIZ SESSIONS ===
  List<Map<String, dynamic>> getAllAnswers() {
    final json = prefs.getString(_answersKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>(),
    );
  }

  Future<void> saveAnswers(List<Map<String, dynamic>> answers) async {
    final existing = getAllAnswers();
    existing.addAll(answers);
    // Son 100 cevabı sakla
    final trimmed = existing.length > 100
        ? existing.sublist(existing.length - 100)
        : existing;
    await prefs.setString(_answersKey, jsonEncode(trimmed));
  }

  List<Map<String, dynamic>> getQuizSessions() {
    final json = prefs.getString(_sessionsKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>(),
    );
  }

  Future<void> saveQuizSession(QuizSession session) async {
    final sessions = getQuizSessions();
    sessions.add(session.toJson());
    await prefs.setString(_sessionsKey, jsonEncode(sessions));
  }

  // === WEEKLY TEST ===
  DateTime? getLastWeeklyTestDate() {
    final ms = prefs.getInt('last_weekly_test');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastWeeklyTestDate(DateTime date) async {
    await prefs.setInt('last_weekly_test', date.millisecondsSinceEpoch);
  }

  bool get isWeeklyTestDue {
    final last = getLastWeeklyTestDate();
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
  }

  // === CLEAR ===
  Future<void> clearAll() async {
    await prefs.clear();
  }
}
