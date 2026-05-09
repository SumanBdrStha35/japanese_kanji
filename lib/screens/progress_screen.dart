import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jap_n5_learn/providers/kanji_provider.dart';

/// Progress and analytics screen
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<KanjiProvider>(
        builder: (context, kanjiProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Overall Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'Total Learned',
                          value:
                              '${kanjiProvider.getLearnedKanjiCount()} / 500',
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Weak Kanji',
                          value: kanjiProvider.getWeakKanjiCount().toString(),
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Current Level',
                          value: 'Level ${kanjiProvider.level}',
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Total XP',
                          value: kanjiProvider.userXP.toString(),
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Daily Streak',
                          value: '${kanjiProvider.dailyStreak} days 🔥',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Learning Percentage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress'),
                            Text(
                              '${((kanjiProvider.getLearnedKanjiCount() / 500) * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: kanjiProvider.getLearnedKanjiCount() / 500,
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent Achievements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Complete quizzes and learn kanji to unlock achievements!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Reusable stat row widget
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
