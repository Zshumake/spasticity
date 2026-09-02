import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's light/dark preference and persists it locally so the
/// user's choice survives a restart (mirrors [FavoritesManager]'s pattern).
///
/// Defaults to following the system appearance: on iOS a dark-only app that
/// ignores the Light/Dark setting reads as broken, and clinicians in a bright
/// room may have chosen light for a reason.
class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _storageKey = 'theme_mode';

  ThemeManager() {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (prefs.getString(_storageKey)) {
        case 'light':
          _themeMode = ThemeMode.light;
          notifyListeners();
        case 'dark':
          _themeMode = ThemeMode.dark;
          notifyListeners();
        case 'system':
          _themeMode = ThemeMode.system;
          notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  void toggleTheme(bool isDark) => setMode(isDark ? ThemeMode.dark : ThemeMode.light);

  void setMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, switch (_themeMode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      });
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
