import 'package:flutter/material.dart';

/// Achievement badge widget
class AchievementBadge extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.isUnlocked,
    this.unlockedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.amber.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? Colors.amber : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked && unlockedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Unlocked',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Locked',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
