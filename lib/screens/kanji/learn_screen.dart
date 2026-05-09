import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jap_n5_learn/models/kanji_model.dart';
import 'package:jap_n5_learn/providers/kanji_provider.dart';
import 'package:jap_n5_learn/data/repositories/kanji_repository.dart';
import 'package:jap_n5_learn/widgets/kanji_card.dart';
import 'package:jap_n5_learn/config/constants.dart';

/// Learn screen for studying kanji
class LearnScreen extends StatefulWidget {
  final int? initialWeek;
  final int? initialDay;

  const LearnScreen({super.key, this.initialWeek, this.initialDay});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final KanjiRepository _repository = KanjiRepository();
  late int _selectedWeek;
  late int _selectedDay;
  bool _showUnlearnedOnly = false;
  late List<KanjiModel> _displayedKanji;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.initialWeek ?? 1;
    _selectedDay = widget.initialDay ?? 1;
    _loadKanji();
  }

  void _loadKanji() {
    final kanjiProvider = context.read<KanjiProvider>();
    final allKanji = _repository.getKanjiByWeekDay(_selectedWeek, _selectedDay);

    if (_showUnlearnedOnly) {
      _displayedKanji = _repository.getUnlearnedKanjiByWeekDay(
        _selectedWeek,
        _selectedDay,
        kanjiProvider.learnedKanjiIds,
      );
    } else {
      _displayedKanji = allKanji;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Kanji'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Week & Day selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week Selector
                Text(
                  'Week $_selectedWeek',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.weeksInStudyPlan,
                    itemBuilder: (context, index) {
                      final week = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Week $week'),
                          selected: _selectedWeek == week,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedWeek = week;
                                _selectedDay = 1;
                              });
                              _loadKanji();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Day Selector
                Text(
                  'Day $_selectedDay',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.daysPerWeek,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Day $day'),
                          selected: _selectedDay == day,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDay = day;
                              });
                              _loadKanji();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Filter Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_displayedKanji.length} Kanji',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                FilterChip(
                  label: const Text('Unlearned Only'),
                  selected: _showUnlearnedOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showUnlearnedOnly = selected;
                    });
                    _loadKanji();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kanji Cards
          Expanded(
            child: _displayedKanji.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showUnlearnedOnly
                              ? 'All kanji learned! 🎉'
                              : 'No kanji available',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _displayedKanji.length,
                    itemBuilder: (context, index) {
                      return KanjiCard(
                        kanji: _displayedKanji[index],
                        onLearned: () {
                          context.read<KanjiProvider>().markKanjiAsLearned(
                            _displayedKanji[index].id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kanji marked as learned! +10 XP'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
