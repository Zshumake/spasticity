import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import '../models/muscle.dart';
import 'muscle_data.dart';

class MuscleDataProvider extends ChangeNotifier {
  List<Muscle> _muscles = [];
  bool _isLoaded = false;

  /// Ids whose ultrasound scan is actually bundled. Muscles without a scan
  /// are HIDDEN from every list (decision 2026-08-30) but stay in the data -
  /// findById still resolves them, and bundling a scan un-hides them with no
  /// code change. Null until the manifest loads (treat as "show all").
  Set<String>? _scannedIds;

  /// Only the muscles with an ultrasound attached - what the app displays.
  List<Muscle> get muscles => _scannedIds == null
      ? _muscles
      : _muscles.where((m) => _scannedIds!.contains(m.id)).toList();

  /// The complete dataset, hidden muscles included.
  List<Muscle> get allMuscles => _muscles;

  bool isVisible(String id) => _scannedIds?.contains(id) ?? true;
  bool get isLoaded => _isLoaded;

  MuscleDataProvider() { _load(); }

  Future<void> _load() async {
    _muscles = await MuscleData.load();
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets().toSet();
      // A muscle is scanned if ANY of its ultrasound approaches is bundled —
      // multi-view muscles stay visible as long as one window exists.
      _scannedIds = _muscles
          .where((m) => m.resolvedUltrasoundViews
              .any((v) => assets.contains(v.scanAsset)))
          .map((m) => m.id)
          .toSet();
    } catch (_) {
      _scannedIds = null; // no manifest (tests, tools): show everything
    }
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

  /// All unique group names for sidebar categories (visible muscles only)
  List<String> get groups {
    final g = muscles.map((m) => m.group).toSet().toList();
    g.sort();
    return g;
  }
}
