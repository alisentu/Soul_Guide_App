// lib/models/quiz_question.dart
class QuizOption {
  final String id;
  final String text;
  final String? subtitle;
  final String? icon;
  final List<String> tags;

  const QuizOption({
    required this.id,
    required this.text,
    this.subtitle,
    this.icon,
    this.tags = const [],
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
        id: json['id'] as String? ?? json['text'].toString().toLowerCase().replaceAll(' ', '_'),
        text: json['text'] as String,
        subtitle: json['subtitle'] as String?,
        icon: json['icon'] as String?,
        tags: List<String>.from(json['tags'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'subtitle': subtitle,
        'icon': icon,
        'tags': tags,
      };
}

class QuizQuestion {
  final String id;
  final String question;
  final String? subtitle;
  final String? icon;
  final List<QuizOption> options;
  final bool isWeekly;

  const QuizQuestion({
    required this.id,
    required this.question,
    this.subtitle,
    this.icon,
    required this.options,
    this.isWeekly = false,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String? ?? DateTime.now().toString(),
        question: json['question'] as String,
        subtitle: json['subtitle'] as String?,
        icon: json['icon'] as String?,
        options: (json['options'] as List<dynamic>)
            .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        isWeekly: json['isWeekly'] as bool? ?? false,
      );
}

class QuizSession {
  final String id;
  final List<QuizQuestion> questions;
  final Map<String, String> answers; // questionId -> optionId
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isWeekly;

  const QuizSession({
    required this.id,
    required this.questions,
    this.answers = const {},
    required this.startedAt,
    this.completedAt,
    this.isWeekly = false,
  });

  QuizSession copyWith({
    Map<String, String>? answers,
    DateTime? completedAt,
  }) {
    return QuizSession(
      id: id,
      questions: questions,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      isWeekly: isWeekly,
    );
  }

  double get completionRate =>
      questions.isEmpty ? 0 : answers.length / questions.length;

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'answers': answers,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isWeekly': isWeekly,
      };
}
