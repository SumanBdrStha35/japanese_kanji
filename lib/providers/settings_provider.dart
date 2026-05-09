import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jap_n5_learn/models/mission_model.dart';
import 'package:jap_n5_learn/config/constants.dart';
import 'dart:convert';

/// Provider managing app settings and daily missions
class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final List<MissionModel> _dailyMissions = [];
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  // Getters
  List<MissionModel> get dailyMissions => _dailyMissions;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  List<MissionModel> get activeMissions =>
      _dailyMissions.where((m) => !m.isCompleted).toList();
  List<MissionModel> get completedMissions =>
      _dailyMissions.where((m) => m.isCompleted).toList();

  SettingsProvider() {
    _initialize();
  }

  /// Initialize settings provider
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadMissions();
    _initializeDailyMissions();
  }

  /// Initialize default daily missions
  void _initializeDailyMissions() {
    if (_dailyMissions.isEmpty) {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      _dailyMissions.addAll([
        MissionModel(
          id: 'mission_learn_5',
          type: MissionType.learnKanji,
          title: 'Learn 5 Kanji',
          description: 'Learn 5 new kanji today',
          target: 5,
          progress: 0,
          rewardXP: 30,
          rewardCoins: 10,
          isCompleted: false,
          dueDate: tomorrow,
        ),
        MissionModel(
          id: 'mission_quiz_1',
          type: MissionType.completeQuiz,
          title: 'Complete a Quiz',
          description: 'Complete any quiz',
          target: 1,
          progress: 0,
          rewardXP: 50,
          rewardCoins: 15,
          isCompleted: false,
          dueDate: tomorrow,
        ),
        MissionModel(
          id: 'mission_login',
          type: MissionType.dailyLogin,
          title: 'Daily Login',
          description: 'Log in today',
          target: 1,
          progress: 1,
          rewardXP: 15,
          rewardCoins: 5,
          isCompleted: false,
          dueDate: tomorrow,
        ),
      ]);
      _saveMissions();
    }
  }

  /// Update mission progress
  Future<void> updateMissionProgress(
    String missionId,
    int progressAmount,
  ) async {
    final index = _dailyMissions.indexWhere((m) => m.id == missionId);
    if (index != -1) {
      final mission = _dailyMissions[index];
      final newProgress = (mission.progress + progressAmount).clamp(
        0,
        mission.target,
      );
      final isCompleted = newProgress >= mission.target;

      _dailyMissions[index] = MissionModel(
        id: mission.id,
        type: mission.type,
        title: mission.title,
        description: mission.description,
        target: mission.target,
        progress: newProgress,
        rewardXP: mission.rewardXP,
        rewardCoins: mission.rewardCoins,
        isCompleted: mission.isCompleted || isCompleted,
        dueDate: mission.dueDate,
      );

      await _saveMissions();
      notifyListeners();
    }
  }

  /// Mark mission as completed
  Future<void> completeMission(String missionId) async {
    final index = _dailyMissions.indexWhere((m) => m.id == missionId);
    if (index != -1) {
      final mission = _dailyMissions[index];
      _dailyMissions[index] = MissionModel(
        id: mission.id,
        type: mission.type,
        title: mission.title,
        description: mission.description,
        target: mission.target,
        progress: mission.target,
        rewardXP: mission.rewardXP,
        rewardCoins: mission.rewardCoins,
        isCompleted: true,
        dueDate: mission.dueDate,
      );

      await _saveMissions();
      notifyListeners();
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _prefs.setBool('notifications_enabled', _notificationsEnabled);
    notifyListeners();
  }

  /// Toggle sound
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _prefs.setBool('sound_enabled', _soundEnabled);
    notifyListeners();
  }

  /// Reset daily missions
  Future<void> resetDailyMissions() async {
    _dailyMissions.clear();
    _initializeDailyMissions();
    notifyListeners();
  }

  /// Save missions to storage
  Future<void> _saveMissions() async {
    try {
      await _prefs.setString(
        AppConstants.storageKeyMissions,
        jsonEncode(_dailyMissions.map((m) => m.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving missions: $e');
    }
  }

  /// Load missions from storage
  Future<void> _loadMissions() async {
    try {
      final missionsJson = _prefs.getString(AppConstants.storageKeyMissions);
      if (missionsJson != null) {
        final decoded = jsonDecode(missionsJson) as List;
        _dailyMissions.clear();
        _dailyMissions.addAll(
          decoded.map((item) => MissionModel.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading missions: $e');
    }
  }
}
