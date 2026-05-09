import 'package:flutter/foundation.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';
import 'package:jap_n5_learn/data/repositories/quiz_repository.dart';

/// Provider managing quiz state and operations
class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepository = QuizRepository();

  List<QuizQuestionModel> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = {}; // Question ID -> Answer
  QuizType _currentQuizType = QuizType.meaning;
  bool _isQuizActive = false;

  // Getters
  List<QuizQuestionModel> get questions => _currentQuestions;
  int get currentIndex => _currentQuestionIndex;
  QuizQuestionModel? get currentQuestion =>
      _currentQuestionIndex < _currentQuestions.length
      ? _currentQuestions[_currentQuestionIndex]
      : null;
  Map<String, String> get userAnswers => _userAnswers;
  bool get isQuizActive => _isQuizActive;
  int get questionsCount => _currentQuestions.length;
  int get answeredCount => _userAnswers.length;
  bool get isQuizComplete => _userAnswers.length == _currentQuestions.length;
  double get progressPercentage =>
      questionsCount > 0 ? (answeredCount / questionsCount).clamp(0, 1) : 0;

  /// Start a new quiz
  void startQuiz(QuizType type, List<QuizQuestionModel> questions) {
    _currentQuizType = type;
    _currentQuestions = questions;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _isQuizActive = true;
    notifyListeners();
  }

  /// Answer current question
  void answerQuestion(String answer) {
    if (currentQuestion != null) {
      _userAnswers[currentQuestion!.id] = answer;
      notifyListeners();
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Get result of current quiz
  QuizResultModel? getQuizResult() {
    if (!isQuizComplete) return null;

    int correctCount = 0;
    final weakKanjiIds = <String>[];

    for (final question in _currentQuestions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer == question.correctAnswer) {
        correctCount++;
      } else {
        weakKanjiIds.add(question.kanjiId);
      }
    }

    final xpEarned = _quizRepository.calculateXP(
      correctCount,
      _currentQuestions.length,
    );

    return QuizResultModel(
      id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      quizType: _currentQuizType,
      totalQuestions: _currentQuestions.length,
      correctAnswers: correctCount,
      xpEarned: xpEarned,
      weakKanjiIds: weakKanjiIds,
      userAnswers: _userAnswers,
    );
  }

  /// End quiz
  void endQuiz() {
    _isQuizActive = false;
    _currentQuestionIndex = 0;
    _currentQuestions = [];
    _userAnswers.clear();
    notifyListeners();
  }

  /// Check if answer to current question is correct
  bool isCurrentAnswerCorrect() {
    if (currentQuestion == null) return false;
    final userAnswer = _userAnswers[currentQuestion!.id];
    return userAnswer == currentQuestion!.correctAnswer;
  }

  /// Get answer to current question
  String? getCurrentAnswer() {
    if (currentQuestion == null) return null;
    return _userAnswers[currentQuestion!.id];
  }
}
