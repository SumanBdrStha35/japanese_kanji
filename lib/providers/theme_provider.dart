import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jap_n5_learn/config/constants.dart';

/// Provider managing theme (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  // Getter
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider();

  /// Initialize theme provider.
  ///
  /// Call this once from `main()` before building the app.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(AppConstants.storageKeyDarkMode) ?? false;
    _isInitialized = true;
    notifyListeners();
  }


  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(AppConstants.storageKeyDarkMode, _isDarkMode);
    notifyListeners();
  }

  /// Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _prefs.setBool(AppConstants.storageKeyDarkMode, isDark);
      notifyListeners();
    }
  }
}
