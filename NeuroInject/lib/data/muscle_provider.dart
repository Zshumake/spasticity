import 'package:flutter/material.dart';
import '../models/muscle.dart';
import 'muscle_data.dart';

class MuscleDataProvider extends ChangeNotifier {
  List<Muscle> _muscles = [];
  bool _isLoaded = false;

  List<Muscle> get muscles => _muscles;
  bool get isLoaded => _isLoaded;

  MuscleDataProvider() { _load(); }

  Future<void> _load() async {
    _muscles = await MuscleData.load();
    _isLoaded = true;
    notifyListeners();
  }

  Muscle? findById(String id) {
    try {
      return _muscles.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// All unique group names for sidebar categories
  List<String> get groups {
    final g = _muscles.map((m) => m.group).toSet().toList();
    g.sort();
    return g;
  }
}
