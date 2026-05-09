/// Model representing the 5-week study plan
class StudyPlanModel {
  final int week;
  final List<DayPlan> days; // 7 days per week
  final bool isCompleted;

  StudyPlanModel({
    required this.week,
    required this.days,
    this.isCompleted = false,
  });
}

/// Model representing a single day in the study plan
class DayPlan {
  final int day;
  final int kanjiCount;
  final bool isReviewDay;
  final bool isCompleted;
  final List<String> kanjiIds; // IDs of kanji for this day

  DayPlan({
    required this.day,
    required this.kanjiCount,
    required this.isReviewDay,
    required this.isCompleted,
    required this.kanjiIds,
  });
}
