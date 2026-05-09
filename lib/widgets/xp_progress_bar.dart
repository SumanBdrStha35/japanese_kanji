import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

/// XP progress bar widget showing progress toward next level
class XPProgressBar extends StatelessWidget {
  final int currentLevel;
  final double progressPercentage;
  final int currentXP;
  final int xpToNextLevel;

  const XPProgressBar({
    super.key,
    required this.currentLevel,
    required this.progressPercentage,
    required this.currentXP,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      'Level $currentLevel',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentXP / ${currentXP + xpToNextLevel} XP',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$xpToNextLevel XP left',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              percent: progressPercentage.clamp(0, 1),
              lineHeight: 12,
              barRadius: const Radius.circular(6),
              progressColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
