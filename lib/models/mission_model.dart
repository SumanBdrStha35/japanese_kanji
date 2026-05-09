/// Model representing a daily mission
enum MissionType { learnKanji, completeQuiz, dailyLogin, reviewKanji }

class MissionModel {
  final String id;
  final MissionType type;
  final String title;
  final String description;
  final int target; // e.g., "Learn 5 kanji"
  final int progress; // Current progress toward target
  final int rewardXP;
  final int rewardCoins;
  final bool isCompleted;
  final DateTime dueDate;

  MissionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.rewardXP,
    required this.rewardCoins,
    required this.isCompleted,
    required this.dueDate,
  });

  double get progressPercentage => (progress / target).clamp(0, 1);
  bool get canClaim => progress >= target && !isCompleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
    'description': description,
    'target': target,
    'progress': progress,
    'rewardXP': rewardXP,
    'rewardCoins': rewardCoins,
    'isCompleted': isCompleted,
    'dueDate': dueDate.toIso8601String(),
  };

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
    id: json['id'],
    type: MissionType.values.firstWhere((e) => e.toString() == json['type']),
    title: json['title'],
    description: json['description'],
    target: json['target'],
    progress: json['progress'],
    rewardXP: json['rewardXP'],
    rewardCoins: json['rewardCoins'],
    isCompleted: json['isCompleted'],
    dueDate: DateTime.parse(json['dueDate']),
  );
}
