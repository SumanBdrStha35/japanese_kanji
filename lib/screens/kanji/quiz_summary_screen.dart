import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';
import 'package:jap_n5_learn/providers/kanji_provider.dart';
import 'package:jap_n5_learn/data/repositories/kanji_repository.dart';

/// Quiz summary screen showing results and statistics
class QuizSummaryScreen extends StatelessWidget {
  final QuizResultModel result;

  const QuizSummaryScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final kanjiRepository = KanjiRepository();
    final weakKanji = kanjiRepository.getKanjiByIds(result.weakKanjiIds);
    final accuracy = result.accuracy;
    final isExcellent = accuracy >= 80;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Complete!'),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Result Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isExcellent
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isExcellent ? Icons.celebration : Icons.thumb_up,
                    size: 60,
                    color: isExcellent ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Score
              Text(
                '${result.correctAnswers}/${result.totalQuestions}',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Correct Answers',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Accuracy
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Accuracy',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${accuracy.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: accuracy / 100,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // XP Earned
              Card(
                color: Colors.amber.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '+${result.xpEarned} XP Earned',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Weak Kanji
              if (weakKanji.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kanji to Review',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: weakKanji.map((kanji) {
                            return Chip(
                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    kanji.kanji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    kanji.meaning,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange.withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<KanjiProvider>();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Try Another Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
