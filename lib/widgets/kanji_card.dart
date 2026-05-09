import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jap_n5_learn/models/kanji_model.dart';
import 'package:jap_n5_learn/providers/kanji_provider.dart';

/// Reusable Kanji card widget displaying kanji and its details
class KanjiCard extends StatefulWidget {
  final KanjiModel kanji;
  final VoidCallback? onLearned;

  const KanjiCard({super.key, required this.kanji, this.onLearned});

  @override
  State<KanjiCard> createState() => _KanjiCardState();
}

class _KanjiCardState extends State<KanjiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showKunyomi = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleReading() {
    if (_showKunyomi) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _showKunyomi = !_showKunyomi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KanjiProvider>(
      builder: (context, kanjiProvider, _) {
        final isLearned = kanjiProvider.learnedKanjiIds.contains(
          widget.kanji.id,
        );
        final isWeak = kanjiProvider.weakKanjiIds.contains(widget.kanji.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isLearned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'Learned ✓',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isWeak)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Weak ⚠️',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '${widget.kanji.strokeCount} strokes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Large Kanji
                Center(
                  child: Text(
                    widget.kanji.kanji,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Meaning
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Meaning',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.kanji.meaning,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Readings (Onyomi and Kunyomi)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Onyomi',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.kanji.onyomi,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          if (widget.kanji.kunyomi.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kunyomi',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.kanji.kunyomi,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Example Vocabulary
                Text(
                  'Example Words',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.kanji.examples
                      .map(
                        (example) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                example,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement TTS
                        },
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Pronounce'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isLearned)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onLearned?.call();
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Learned'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
