import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedManager extends ChangeNotifier {
  List<String> _recentIds = [];
  static const String _storageKey = 'recently_viewed_muscles';
  static const int _maxRecent = 10;

  RecentlyViewedManager() { _load(); }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_storageKey);
      if (saved != null) {
        _recentIds = saved;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
    }
  }

  List<String> get recentIds => List.unmodifiable(_recentIds);

  void recordView(String id) async {
    _recentIds.remove(id);
    _recentIds.insert(0, id);
    if (_recentIds.length > _maxRecent) {
      _recentIds = _recentIds.sublist(0, _maxRecent);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _recentIds);
    } catch (e) {
      debugPrint('Error saving recently viewed: $e');
    }
  }
}
