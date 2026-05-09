/// App-wide constants and configuration values
class AppConstants {
  // App Info
  static const String appName = 'JLPT N5 Kanji Learner';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableGamification = true;

  // Kanji Learning
  static const int weeksInStudyPlan = 5;
  static const int daysPerWeek = 7;
  static const int totalKanjiN5 = 500;

  // Gamification Settings
  static const int xpPerKanjiLearned = 10;
  static const int xpPerCorrectQuiz = 5;
  static const int xpPerDailyLogin = 15;
  static const int xpPerReviewCompletion = 50;
  static const int xpPerLevelUp = 100;

  // Quiz Settings
  static const int questionsPerQuiz = 10;
  static const int optionsPerQuestion = 4;

  // Study Plan Review Days
  static const List<int> reviewDays = [7, 14, 21, 28, 35, 42, 49, 50];

  // Storage Keys
  static const String storageKeyLearnedKanji = 'learned_kanji';
  static const String storageKeyWeakKanji = 'weak_kanji';
  static const String storageKeyUserXP = 'user_xp';
  static const String storageKeyUserLevel = 'user_level';
  static const String storageKeyDailyStreak = 'daily_streak';
  static const String storageKeyLastLoginDate = 'last_login_date';
  static const String storageKeyDarkMode = 'dark_mode';
  static const String storageKeyQuizHistory = 'quiz_history';
  static const String storageKeyAchievements = 'achievements';
  static const String storageKeyMissions = 'missions';
  static const String storageKeyCoins = 'coins';

  // Achievement Thresholds
  static const int achievementKanjiCount = 50;
  static const int achievementStreakDays = 7;
  static const int achievementPerfectScore = 100;
}

/// Rank titles based on level
const rankTitles = {
  1: 'Beginner',
  5: 'Student',
  10: 'Novice',
  15: 'Scholar',
  20: 'Advanced Scholar',
  25: 'Expert',
  30: 'Master',
  35: 'Kanji Master',
};

String getRankTitle(int level) {
  for (int threshold
      in rankTitles.keys.toList()..sort((a, b) => b.compareTo(a))) {
    if (level >= threshold) {
      return rankTitles[threshold]!;
    }
  }
  return 'Beginner';
}
