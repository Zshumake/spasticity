import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's light/dark preference and persists it locally so the
/// user's choice survives a restart (mirrors [FavoritesManager]'s pattern).
class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
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
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, isDarkMode ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
