import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jap_n5_learn/models/kanji_model.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';
import 'package:jap_n5_learn/providers/kanji_provider.dart';
import 'package:jap_n5_learn/providers/quiz_provider.dart';
import 'package:jap_n5_learn/data/repositories/kanji_repository.dart';
import 'package:jap_n5_learn/data/repositories/quiz_repository.dart';
import 'package:jap_n5_learn/widgets/quiz_question_widget.dart';
import 'package:jap_n5_learn/screens/kanji/quiz_summary_screen.dart';

/// Quiz mode screen with question flow
class QuizScreen extends StatefulWidget {
  final QuizType quizType;
  final List<KanjiModel>? selectedKanji;

  const QuizScreen({
    super.key,
    required this.quizType,
    this.selectedKanji,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final KanjiRepository _kanjiRepository = KanjiRepository();
  final QuizRepository _quizRepository = QuizRepository();

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    final kanjiProvider = context.read<KanjiProvider>();
    final selectedKanji = widget.selectedKanji ??
        _kanjiRepository.getKanjiByIds(
          kanjiProvider.learnedKanjiIds.take(20).toList(),
        );

    if (selectedKanji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Learn some kanji first!'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final questions = _quizRepository.generateQuiz(
      widget.quizType,
      selectedKanji,
    );

    context.read<QuizProvider>().startQuiz(widget.quizType, questions);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        if (!quizProvider.isQuizActive || quizProvider.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (quizProvider.isQuizComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final result = quizProvider.getQuizResult();
            if (result != null) {
              context.read<KanjiProvider>().recordQuizResult(result);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => QuizSummaryScreen(result: result),
                ),
              );
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz'),
            centerTitle: true,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '${quizProvider.currentIndex + 1}/${quizProvider.questionsCount}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: quizProvider.progressPercentage,
                minHeight: 4,
              ),

              // Question
              Expanded(
                child: QuizQuestionWidget(
                  question: quizProvider.currentQuestion!,
                  onAnswerSelected: (answer) {
                    quizProvider.answerQuestion(answer);
                  },
                  selectedAnswer: quizProvider.getCurrentAnswer(),
                  isAnswered: quizProvider.getCurrentAnswer() != null,
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (quizProvider.currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            quizProvider.previousQuestion();
                          },
                          child: const Text('Previous'),
                        ),
                      ),
                    if (quizProvider.currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: quizProvider.getCurrentAnswer() != null
                            ? () {
                                if (quizProvider.currentIndex <
                                    quizProvider.questionsCount - 1) {
                                  quizProvider.nextQuestion();
                                } else {
                                  // Quiz complete
                                  quizProvider.endQuiz();
                                }
                              }
                            : null,
                        child: Text(
                          quizProvider.currentIndex == quizProvider.questionsCount - 1
                              ? 'Finish'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
