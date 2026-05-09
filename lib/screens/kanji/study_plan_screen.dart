import 'package:flutter/material.dart';
import 'package:jap_n5_learn/config/constants.dart';
import 'package:jap_n5_learn/data/repositories/kanji_repository.dart';
import 'package:jap_n5_learn/screens/kanji/learn_screen.dart';
import 'package:jap_n5_learn/screens/kanji/quiz_screen.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';

/// Study plan screen showing 5-week N5 kanji learning schedule
class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final KanjiRepository _repository = KanjiRepository();
  late List<bool> _expandedWeeks;

  @override
  void initState() {
    super.initState();
    _expandedWeeks = List.filled(5, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Week Study Plan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JLPT N5 Kanji Curriculum',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Master 500 kanji in 5 weeks with daily lessons and review days',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ...List.generate(AppConstants.weeksInStudyPlan, (weekIndex) {
              final week = weekIndex + 1;
              final kanjiForWeek = _repository.getKanjiByWeek(week);

              return _WeekCard(
                week: week,
                kanjiCount: kanjiForWeek.length,
                isExpanded: _expandedWeeks[weekIndex],
                onExpanded: (expanded) {
                  setState(() {
                    _expandedWeeks[weekIndex] = expanded;
                  });
                },
                repository: _repository,
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Week card showing daily schedule and review days
class _WeekCard extends StatelessWidget {
  final int week;
  final int kanjiCount;
  final bool isExpanded;
  final Function(bool) onExpanded;
  final KanjiRepository repository;

  const _WeekCard({
    required this.week,
    required this.kanjiCount,
    required this.isExpanded,
    required this.onExpanded,
    required this.repository,
  });

  bool _isReviewDay(int day) {
    return AppConstants.reviewDays.contains(day);
  }

  int _getDayNumber(int day) {
    // Convert day 1-7 to actual day number in study plan
    return (week - 1) * 7 + day;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'W$week',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week $week',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$kanjiCount kanji',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        onExpansionChanged: onExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Schedule',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 12),
                ...List.generate(AppConstants.daysPerWeek, (dayIndex) {
                  final day = dayIndex + 1;
                  final isReview = _isReviewDay(_getDayNumber(day));
                  final kanjiForDay = repository.getKanjiByWeekDay(week, day);

                  return _DayTile(
                    week: week,
                    day: day,
                    kanjiCount: kanjiForDay.length,
                    isReviewDay: isReview,
                    repository: repository,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Day tile showing kanji count and action buttons
class _DayTile extends StatelessWidget {
  final int week;
  final int day;
  final int kanjiCount;
  final bool isReviewDay;
  final KanjiRepository repository;

  const _DayTile({
    required this.week,
    required this.day,
    required this.kanjiCount,
    required this.isReviewDay,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReviewDay
            ? Colors.orange.withOpacity(0.05)
            : Colors.transparent,
        border: Border.all(
          color: isReviewDay ? Colors.orange : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Day $day',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    if (isReviewDay)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$kanjiCount kanji',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LearnScreen(initialWeek: week, initialDay: day),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book, size: 16),
                  label: const Text('Learn'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final kanjiForDay = repository.getKanjiByWeekDay(week, day);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          quizType: QuizType.mixed,
                          selectedKanji: kanjiForDay,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz, size: 16),
                  label: const Text('Quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
