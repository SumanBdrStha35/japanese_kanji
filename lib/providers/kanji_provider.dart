import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jap_n5_learn/models/user_progress_model.dart';
import 'package:jap_n5_learn/models/quiz_model.dart';
import 'package:jap_n5_learn/config/constants.dart';
import 'dart:convert';

/// Main provider managing Kanji learning progress and state
class KanjiProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  late UserProgressModel _progress;
  final List<QuizResultModel> _quizHistory = [];

  // Getters
  Set<String> get learnedKanjiIds => _progress.learnedKanjiIds;
  Set<String> get weakKanjiIds => _progress.weakKanjiIds;
  int get userXP => _progress.totalXP;
  int get level => _progress.level;
  int get dailyStreak => _progress.dailyStreak;
  int get coins => _progress.coins;
  DateTime get lastLoginDate => _progress.lastLoginDate;
  List<QuizResultModel> get quizHistory => _quizHistory;

  KanjiProvider() {
    _initialize();
  }

  /// Initialize the provider and load saved data
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
    await _checkDailyLogin();
  }

  /// Load progress from storage
  Future<void> _loadProgress() async {
    try {
      final learnedJson = _prefs.getString(AppConstants.storageKeyLearnedKanji);
      final weakJson = _prefs.getString(AppConstants.storageKeyWeakKanji);
      final xp = _prefs.getInt(AppConstants.storageKeyUserXP) ?? 0;
      final level = _prefs.getInt(AppConstants.storageKeyUserLevel) ?? 1;
      final streak = _prefs.getInt(AppConstants.storageKeyDailyStreak) ?? 0;
      final coins = _prefs.getInt(AppConstants.storageKeyCoins) ?? 0;
      final lastLoginStr = _prefs.getString(
        AppConstants.storageKeyLastLoginDate,
      );

      _progress = UserProgressModel(
        learnedKanjiIds: learnedJson != null
            ? Set<String>.from(jsonDecode(learnedJson))
            : {},
        weakKanjiIds: weakJson != null
            ? Set<String>.from(jsonDecode(weakJson))
            : {},
        totalXP: xp,
        level: UserProgressModel.calculateLevel(xp),
        dailyStreak: streak,
        coins: coins,
        lastLoginDate: lastLoginStr != null
            ? DateTime.parse(lastLoginStr)
            : DateTime.now(),
      );

      // Load quiz history
      await _loadQuizHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading progress: $e');
      _progress = UserProgressModel(
        learnedKanjiIds: {},
        weakKanjiIds: {},
        totalXP: 0,
        level: 1,
        dailyStreak: 0,
        coins: 0,
        lastLoginDate: DateTime.now(),
      );
    }
  }

  /// Check if user logged in today and update streak
  Future<void> _checkDailyLogin() async {
    final now = DateTime.now();
    final lastLogin = _progress.lastLoginDate;
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

    // Check if last login was yesterday (continuous streak)
    final dayDifference = today.difference(yesterday).inDays;

    if (dayDifference == 0) {
      // Logged in today already, no change
      return;
    } else if (dayDifference == 1) {
      // Logged in yesterday, continue streak
      await addXP(AppConstants.xpPerDailyLogin);
      incrementStreak();
    } else {
      // Streak broken
      resetDailyStreak();
    }
  }

  /// Mark kanji as learned and award XP
  Future<void> markKanjiAsLearned(String kanjiId) async {
    if (!_progress.learnedKanjiIds.contains(kanjiId)) {
      _progress.learnedKanjiIds.add(kanjiId);
      _progress.weakKanjiIds.remove(kanjiId);
      await addXP(AppConstants.xpPerKanjiLearned);
      await _saveProgress();
      notifyListeners();
    }
  }

  /// Mark kanji as weak
  Future<void> markKanjiAsWeak(String kanjiId) async {
    _progress.weakKanjiIds.add(kanjiId);
    await _saveProgress();
    notifyListeners();
  }

  /// Add XP and check for level up
  Future<void> addXP(int amount) async {
    final oldLevel = _progress.level;
    _progress = _progress.copyWith(totalXP: _progress.totalXP + amount);

    // Recalculate level
    final newLevel = UserProgressModel.calculateLevel(_progress.totalXP);
    _progress = _progress.copyWith(level: newLevel);

    // Check for level up
    if (newLevel > oldLevel) {
      await _celebrateLevelUp(newLevel);
    }

    await _saveProgress();
    notifyListeners();
  }

  /// Level up celebration (add coins bonus)
  Future<void> _celebrateLevelUp(int newLevel) async {
    final coinBonus = newLevel * 10; // 10 coins per level
    _progress = _progress.copyWith(coins: _progress.coins + coinBonus);
  }

  /// Increment daily streak
  void incrementStreak() {
    _progress = _progress.copyWith(
      dailyStreak: _progress.dailyStreak + 1,
      lastLoginDate: DateTime.now(),
    );
    notifyListeners();
  }

  /// Reset daily streak
  Future<void> resetDailyStreak() async {
    _progress = _progress.copyWith(
      dailyStreak: 0,
      lastLoginDate: DateTime.now(),
    );
    await _saveProgress();
    notifyListeners();
  }

  /// Add coins
  Future<void> addCoins(int amount) async {
    _progress = _progress.copyWith(coins: _progress.coins + amount);
    await _saveProgress();
    notifyListeners();
  }

  /// Record quiz result
  Future<void> recordQuizResult(QuizResultModel result) async {
    _quizHistory.add(result);
    await addXP(result.xpEarned);

    // Add weak kanji
    for (final kanjiId in result.weakKanjiIds) {
      await markKanjiAsWeak(kanjiId);
    }

    await _saveQuizHistory();
    notifyListeners();
  }

  /// Get quiz accuracy (average)
  double getQuizAccuracy() {
    if (_quizHistory.isEmpty) return 0;
    final totalAccuracy = _quizHistory.fold<double>(
      0,
      (sum, quiz) => sum + quiz.accuracy,
    );
    return totalAccuracy / _quizHistory.length;
  }

  /// Get learned kanji count
  int getLearnedKanjiCount() => _progress.learnedKanjiIds.length;

  /// Get weak kanji count
  int getWeakKanjiCount() => _progress.weakKanjiIds.length;

  /// Get XP to next level
  int getXPToNextLevel() {
    final currentLevelXP = (_progress.level - 1) * AppConstants.xpPerLevelUp;
    final nextLevelXP = _progress.level * AppConstants.xpPerLevelUp;
    return nextLevelXP - (_progress.totalXP - currentLevelXP);
  }

  /// Get level progress percentage
  double getLevelProgressPercentage() {
    final currentLevelXP = (_progress.level - 1) * AppConstants.xpPerLevelUp;
    final nextLevelXP = _progress.level * AppConstants.xpPerLevelUp;
    final xpInLevel = _progress.totalXP - currentLevelXP;
    final xpNeeded = nextLevelXP - currentLevelXP;
    return (xpInLevel / xpNeeded).clamp(0, 1);
  }

  /// Save progress to storage
  Future<void> _saveProgress() async {
    try {
      await _prefs.setString(
        AppConstants.storageKeyLearnedKanji,
        jsonEncode(_progress.learnedKanjiIds.toList()),
      );
      await _prefs.setString(
        AppConstants.storageKeyWeakKanji,
        jsonEncode(_progress.weakKanjiIds.toList()),
      );
      await _prefs.setInt(AppConstants.storageKeyUserXP, _progress.totalXP);
      await _prefs.setInt(AppConstants.storageKeyUserLevel, _progress.level);
      await _prefs.setInt(
        AppConstants.storageKeyDailyStreak,
        _progress.dailyStreak,
      );
      await _prefs.setInt(AppConstants.storageKeyCoins, _progress.coins);
      await _prefs.setString(
        AppConstants.storageKeyLastLoginDate,
        _progress.lastLoginDate.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  /// Load quiz history from storage
  Future<void> _loadQuizHistory() async {
    try {
      final historyJson = _prefs.getString(AppConstants.storageKeyQuizHistory);
      if (historyJson != null) {
        final decoded = jsonDecode(historyJson) as List;
        _quizHistory.clear();
        _quizHistory.addAll(
          decoded.map((item) => QuizResultModel.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading quiz history: $e');
    }
  }

  /// Save quiz history to storage
  Future<void> _saveQuizHistory() async {
    try {
      await _prefs.setString(
        AppConstants.storageKeyQuizHistory,
        jsonEncode(_quizHistory.map((q) => q.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving quiz history: $e');
    }
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await _prefs.clear();
    _progress = UserProgressModel(
      learnedKanjiIds: {},
      weakKanjiIds: {},
      totalXP: 0,
      level: 1,
      dailyStreak: 0,
      coins: 0,
      lastLoginDate: DateTime.now(),
    );
    _quizHistory.clear();
    notifyListeners();
  }
}
