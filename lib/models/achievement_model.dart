/// Model representing an Achievement/Badge
class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji or icon name
  final bool isUnlocked;
  final DateTime? unlockedDate;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'isUnlocked': isUnlocked,
    'unlockedDate': unlockedDate?.toIso8601String(),
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        isUnlocked: json['isUnlocked'],
        unlockedDate: json['unlockedDate'] != null
            ? DateTime.parse(json['unlockedDate'])
            : null,
      );
}
