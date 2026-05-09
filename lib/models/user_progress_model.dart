/// Model representing user progress and learning state
class UserProgressModel {
  final Set<String> learnedKanjiIds;
  final Set<String> weakKanjiIds;
  final int totalXP;
  final int level;
  final int dailyStreak;
  final int coins;
  final DateTime lastLoginDate;

  UserProgressModel({
    required this.learnedKanjiIds,
    required this.weakKanjiIds,
    required this.totalXP,
    required this.level,
    required this.dailyStreak,
    required this.coins,
    required this.lastLoginDate,
  });

  // Calculate level based on XP (100 XP per level)
  static int calculateLevel(int xp) => (xp ~/ 100) + 1;

  Map<String, dynamic> toJson() => {
    'learnedKanjiIds': learnedKanjiIds.toList(),
    'weakKanjiIds': weakKanjiIds.toList(),
    'totalXP': totalXP,
    'level': level,
    'dailyStreak': dailyStreak,
    'coins': coins,
    'lastLoginDate': lastLoginDate.toIso8601String(),
  };

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      UserProgressModel(
        learnedKanjiIds: Set<String>.from(json['learnedKanjiIds'] ?? []),
        weakKanjiIds: Set<String>.from(json['weakKanjiIds'] ?? []),
        totalXP: json['totalXP'] ?? 0,
        level: json['level'] ?? 1,
        dailyStreak: json['dailyStreak'] ?? 0,
        coins: json['coins'] ?? 0,
        lastLoginDate: json['lastLoginDate'] != null
            ? DateTime.parse(json['lastLoginDate'])
            : DateTime.now(),
      );

  UserProgressModel copyWith({
    Set<String>? learnedKanjiIds,
    Set<String>? weakKanjiIds,
    int? totalXP,
    int? level,
    int? dailyStreak,
    int? coins,
    DateTime? lastLoginDate,
  }) => UserProgressModel(
    learnedKanjiIds: learnedKanjiIds ?? this.learnedKanjiIds,
    weakKanjiIds: weakKanjiIds ?? this.weakKanjiIds,
    totalXP: totalXP ?? this.totalXP,
    level: level ?? this.level,
    dailyStreak: dailyStreak ?? this.dailyStreak,
    coins: coins ?? this.coins,
    lastLoginDate: lastLoginDate ?? this.lastLoginDate,
  );
}
