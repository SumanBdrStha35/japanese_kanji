import 'package:jap_n5_learn/models/kanji_model.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';
import 'package:jap_n5_learn/data/repositories/kanji_repository.dart';
import 'dart:math';

/// Repository for Quiz-related operations
class QuizRepository {
  final KanjiRepository kanjiRepository = KanjiRepository();
  final Random _random = Random();

  /// Generate a quiz question for meaning (kanji -> meaning)
  QuizQuestionModel generateMeaningQuestion(
    KanjiModel targetKanji,
    List<KanjiModel> allKanji,
  ) {
    final options = <String>{targetKanji.meaning};

    // Get random incorrect meanings
    final otherKanji = allKanji.where((k) => k.id != targetKanji.id).toList();
    while (options.length < 4 && otherKanji.isNotEmpty) {
      options.add(otherKanji[_random.nextInt(otherKanji.length)].meaning);
    }

    final shuffledOptions = options.toList()..shuffle();

    return QuizQuestionModel(
      id: '${targetKanji.id}_meaning_${DateTime.now().millisecondsSinceEpoch}',
      kanjiId: targetKanji.id,
      kanji: targetKanji.kanji,
      type: QuizType.meaning,
      correctAnswer: targetKanji.meaning,
      options: shuffledOptions,
      question: 'What is the meaning of ${targetKanji.kanji}?',
    );
  }

  /// Generate a quiz question for reading (kanji -> reading)
  QuizQuestionModel generateReadingQuestion(
    KanjiModel targetKanji,
    List<KanjiModel> allKanji,
  ) {
    final onyomi = targetKanji.onyomi;
    final options = <String>{onyomi};

    // Get random incorrect readings
    final otherKanji = allKanji.where((k) => k.id != targetKanji.id).toList();
    while (options.length < 4 && otherKanji.isNotEmpty) {
      options.add(otherKanji[_random.nextInt(otherKanji.length)].onyomi);
    }

    final shuffledOptions = options.toList()..shuffle();

    return QuizQuestionModel(
      id: '${targetKanji.id}_reading_${DateTime.now().millisecondsSinceEpoch}',
      kanjiId: targetKanji.id,
      kanji: targetKanji.kanji,
      type: QuizType.reading,
      correctAnswer: onyomi,
      options: shuffledOptions,
      question: 'What is the onyomi reading of ${targetKanji.kanji}?',
    );
  }

  /// Generate a quiz question for writing (meaning -> kanji)
  QuizQuestionModel generateWritingQuestion(
    KanjiModel targetKanji,
    List<KanjiModel> allKanji,
  ) {
    final kanji = targetKanji.kanji;
    final options = <String>{kanji};

    // Get random incorrect kanji
    final otherKanji = allKanji.where((k) => k.id != targetKanji.id).toList();
    while (options.length < 4 && otherKanji.isNotEmpty) {
      options.add(otherKanji[_random.nextInt(otherKanji.length)].kanji);
    }

    final shuffledOptions = options.toList()..shuffle();

    return QuizQuestionModel(
      id: '${targetKanji.id}_writing_${DateTime.now().millisecondsSinceEpoch}',
      kanjiId: targetKanji.id,
      kanji: targetKanji.kanji,
      type: QuizType.writingRecall,
      correctAnswer: kanji,
      options: shuffledOptions,
      question: 'Which kanji means "${targetKanji.meaning}"?',
    );
  }

  /// Generate a mixed quiz question (random type)
  QuizQuestionModel generateMixedQuestion(
    KanjiModel targetKanji,
    List<KanjiModel> allKanji,
  ) {
    final types = [QuizType.meaning, QuizType.reading, QuizType.writingRecall];
    final randomType = types[_random.nextInt(types.length)];

    switch (randomType) {
      case QuizType.meaning:
        return generateMeaningQuestion(targetKanji, allKanji);
      case QuizType.reading:
        return generateReadingQuestion(targetKanji, allKanji);
      case QuizType.writingRecall:
        return generateWritingQuestion(targetKanji, allKanji);
      default:
        return generateMeaningQuestion(targetKanji, allKanji);
    }
  }

  /// Generate full quiz (10 questions) of a specific type
  List<QuizQuestionModel> generateQuiz(
    QuizType type,
    List<KanjiModel> selectedKanji,
  ) {
    final questions = <QuizQuestionModel>[];
    final allKanji = kanjiRepository.getAllKanji();

    // Limit to 10 questions or available kanji, whichever is smaller
    final questionCount = min(10, selectedKanji.length);

    for (int i = 0; i < questionCount; i++) {
      final targetKanji = selectedKanji[i];

      switch (type) {
        case QuizType.meaning:
          questions.add(generateMeaningQuestion(targetKanji, allKanji));
          break;
        case QuizType.reading:
          questions.add(generateReadingQuestion(targetKanji, allKanji));
          break;
        case QuizType.writingRecall:
          questions.add(generateWritingQuestion(targetKanji, allKanji));
          break;
        case QuizType.mixed:
          questions.add(generateMixedQuestion(targetKanji, allKanji));
          break;
      }
    }

    return questions;
  }

  /// Calculate XP earned based on accuracy
  int calculateXP(int correctAnswers, int totalQuestions) {
    final accuracy = (correctAnswers / totalQuestions);
    if (accuracy == 1.0) {
      return 50; // Perfect score bonus
    } else if (accuracy >= 0.8) {
      return 30;
    } else if (accuracy >= 0.6) {
      return 20;
    } else if (accuracy >= 0.4) {
      return 10;
    } else {
      return 5;
    }
  }

  /// Identify weak kanji from quiz (incorrect answers)
  List<String> identifyWeakKanji(
    Map<String, String> userAnswers,
    List<QuizQuestionModel> questions,
  ) {
    final weakKanjiIds = <String>[];

    for (final question in questions) {
      final userAnswer = userAnswers[question.id];
      if (userAnswer != question.correctAnswer) {
        weakKanjiIds.add(question.kanjiId);
      }
    }

    return weakKanjiIds;
  }
}
