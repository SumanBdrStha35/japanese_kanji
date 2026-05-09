import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jap_n5_learn/models/achievement_model.dart';
import 'package:jap_n5_learn/config/constants.dart';
import 'dart:convert';

/// Provider managing gamification features (achievements, badges, rewards)
class GamificationProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final List<AchievementModel> _achievements = [];
  final int _totalCoins = 0;

  // Getters
  List<AchievementModel> get achievements => _achievements;
  int get totalCoins => _totalCoins;
  List<AchievementModel> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  int get unlockedCount => unlockedAchievements.length;

  void GameficationProvider() {
    _initialize();
  }

  /// Initialize gamification provider
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAchievements();
    _initializeAchievements();
  }

  /// Initialize default achievements
  void _initializeAchievements() {
    if (_achievements.isEmpty) {
      _achievements.addAll([
        AchievementModel(
          id: 'first_kanji',
          name: 'First Step',
          description: 'Learn your first kanji',
          icon: '🎌',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'fifty_kanji',
          name: 'Kanji Enthusiast',
          description: 'Learn 50 kanji',
          icon: '📚',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'hundred_kanji',
          name: 'Kanji Scholar',
          description: 'Learn 100 kanji',
          icon: '🏆',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'all_kanji',
          name: 'Kanji Master',
          description: 'Learn all 500 N5 kanji',
          icon: '👑',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'perfect_quiz',
          name: 'Perfect Score',
          description: 'Get 100% on a quiz',
          icon: '⭐',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'seven_day_streak',
          name: 'Week Warrior',
          description: 'Maintain a 7-day streak',
          icon: '🔥',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'thirty_day_streak',
          name: 'Legend',
          description: 'Maintain a 30-day streak',
          icon: '⚡',
          isUnlocked: false,
        ),
        AchievementModel(
          id: 'level_10',
          name: 'Rising Star',
          description: 'Reach level 10',
          icon: '🌟',
          isUnlocked: false,
        ),
      ]);
      _saveAchievements();
    }
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      final achievement = _achievements[index];
      _achievements[index] = AchievementModel(
        id: achievement.id,
        name: achievement.name,
        description: achievement.description,
        icon: achievement.icon,
        isUnlocked: true,
        unlockedDate: DateTime.now(),
      );
      await _saveAchievements();
      notifyListeners();
    }
  }

  /// Check and unlock achievements based on progress
  Future<void> checkAchievements({
    required int learnedKanjiCount,
    required int level,
    required int dailyStreak,
    required double quizAccuracy,
  }) async {
    // First kanji
    if (learnedKanjiCount >= 1) {
      await unlockAchievement('first_kanji');
    }

    // Kanji counts
    if (learnedKanjiCount >= 50) {
      await unlockAchievement('fifty_kanji');
    }
    if (learnedKanjiCount >= 100) {
      await unlockAchievement('hundred_kanji');
    }
    if (learnedKanjiCount >= 500) {
      await unlockAchievement('all_kanji');
    }

    // Perfect quiz
    if (quizAccuracy == 100) {
      await unlockAchievement('perfect_quiz');
    }

    // Streaks
    if (dailyStreak >= 7) {
      await unlockAchievement('seven_day_streak');
    }
    if (dailyStreak >= 30) {
      await unlockAchievement('thirty_day_streak');
    }

    // Levels
    if (level >= 10) {
      await unlockAchievement('level_10');
    }
  }

  /// Get achievement by ID
  AchievementModel? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get rank title based on level
  String getRankTitle(int level) {
    return getRankTitle(level);
  }

  /// Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      await _prefs.setString(
        AppConstants.storageKeyAchievements,
        jsonEncode(_achievements.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  /// Load achievements from storage
  Future<void> _loadAchievements() async {
    try {
      final achievementsJson = _prefs.getString(
        AppConstants.storageKeyAchievements,
      );
      if (achievementsJson != null) {
        final decoded = jsonDecode(achievementsJson) as List;
        _achievements.clear();
        _achievements.addAll(
          decoded.map((item) => AchievementModel.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }
}
