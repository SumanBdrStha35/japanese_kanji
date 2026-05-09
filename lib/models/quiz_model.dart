/// Model representing a Quiz Question
enum QuizType { meaning, reading, writingRecall, mixed }

class QuizQuestionModel {
  final String id;
  final String kanjiId;
  final String kanji;
  final QuizType type;
  final String correctAnswer;
  final List<String> options; // 4 options
  final String question;

  QuizQuestionModel({
    required this.id,
    required this.kanjiId,
    required this.kanji,
    required this.type,
    required this.correctAnswer,
    required this.options,
    required this.question,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'kanjiId': kanjiId,
    'kanji': kanji,
    'type': type.toString(),
    'correctAnswer': correctAnswer,
    'options': options,
    'question': question,
  };
}

/// Model representing a Quiz Result
class QuizResultModel {
  final String id;
  final DateTime timestamp;
  final QuizType quizType;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final List<String> weakKanjiIds; // IDs of kanji answered incorrectly
  final Map<String, String> userAnswers; // Question ID -> User Answer

  QuizResultModel({
    required this.id,
    required this.timestamp,
    required this.quizType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    required this.weakKanjiIds,
    required this.userAnswers,
  });

  double get accuracy => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'quizType': quizType.toString(),
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'xpEarned': xpEarned,
    'weakKanjiIds': weakKanjiIds,
    'userAnswers': userAnswers,
  };

  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      QuizResultModel(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        quizType: QuizType.values.firstWhere(
          (e) => e.toString() == json['quizType'],
        ),
        totalQuestions: json['totalQuestions'],
        correctAnswers: json['correctAnswers'],
        xpEarned: json['xpEarned'],
        weakKanjiIds: List<String>.from(json['weakKanjiIds'] ?? []),
        userAnswers: Map<String, String>.from(json['userAnswers'] ?? {}),
      );
}
