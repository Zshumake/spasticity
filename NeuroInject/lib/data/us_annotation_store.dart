import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/us_annotation.dart';

/// Structure letters and presentation crops, per ultrasound scan.
///
/// TWO LAYERS, on purpose.
///
/// The bundled layer is `assets/data/us-annotations.json`: reviewed, committed,
/// and what every reader sees. The draft layer lives in shared_preferences and
/// holds work the author has done on this device but not yet committed. The
/// effective annotation for a scan is the draft if there is one, else the
/// bundled record.
///
/// Authoring therefore shows up immediately on the reference screens — you
/// place a letter and it is there when you go back to the muscle — while
/// nothing reaches other readers until `tools/pull_annotations.py` merges the
/// export into the asset and it is reviewed like any other clinical content.
/// The same shape as the highlight captures: draw in the app, pull to disk,
/// commit.
class UsAnnotationStore extends ChangeNotifier {
  static const String assetPath = 'assets/data/us-annotations.json';
  static const String _prefsKey = 'us_annotations_draft_v1';

  final Map<String, ScanAnnotation> _bundled = {};
  final Map<String, ScanAnnotation> _draft = {};
  bool _loaded = false;

  UsAnnotationStore({bool autoLoad = true}) {
    if (autoLoad) load();
  }

  bool get isLoaded => _loaded;

  /// Scans with unsaved authoring on this device.
  Iterable<String> get draftScans => _draft.keys;
  bool get hasDraft => _draft.isNotEmpty;

  /// Key a scan by file name, so the same picture reached from two muscles
  /// resolves to the same annotation.
  static String keyFor(String scanAsset) => scanAsset.split('/').last;

  /// What should be rendered for this scan. Never null: an unannotated scan is
  /// an empty annotation, not a missing one.
  ScanAnnotation forScan(String scanAsset) {
    final k = keyFor(scanAsset);
    return _draft[k] ?? _bundled[k] ?? const ScanAnnotation();
  }

  bool isDraft(String scanAsset) => _draft.containsKey(keyFor(scanAsset));

  Future<void> load() async {
    await _loadBundled();
    await _loadDraft();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _loadBundled() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      _bundled
        ..clear()
        ..addAll(_parse(raw));
    } catch (_) {
      // Not bundled yet, or unreadable. An absent annotations file is the
      // normal state before anything has been authored, so this is not an
      // error — the scans simply render without letters.
      _bundled.clear();
    }
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      _draft.clear();
      if (raw != null && raw.isNotEmpty) _draft.addAll(_parse(raw));
    } catch (e) {
      debugPrint('us annotations: draft load failed: $e');
    }
  }

  static Map<String, ScanAnnotation> _parse(String raw) {
    final out = <String, ScanAnnotation>{};
    final doc = json.decode(raw);
    final scans = doc is Map<String, dynamic> ? doc['scans'] : null;
    if (scans is Map) {
      scans.forEach((k, v) {
        if (k is String && v is Map<String, dynamic>) {
          out[k] = ScanAnnotation.fromJson(v);
        }
      });
    }
    return out;
  }

  /// Record authoring for one scan. An annotation with nothing in it drops the
  /// draft entry rather than storing an empty object, so "clear everything"
  /// returns the scan to whatever is committed.
  Future<void> put(String scanAsset, ScanAnnotation a) async {
    final k = keyFor(scanAsset);
    if (a.isEmpty) {
      _draft.remove(k);
    } else {
      _draft[k] = a;
    }
    notifyListeners();
    await _persist();
  }

  /// Discard local authoring for one scan, reverting to the committed record.
  Future<void> revert(String scanAsset) async {
    if (_draft.remove(keyFor(scanAsset)) == null) return;
    notifyListeners();
    await _persist();
  }

  Future<void> clearDrafts() async {
    if (_draft.isEmpty) return;
    _draft.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _encode(_draft));
    } catch (e) {
      debugPrint('us annotations: draft save failed: $e');
    }
  }

  /// The file to commit: the bundled record with the drafts merged over it, in
  /// the exact shape `assets/data/us-annotations.json` has. Emitting the whole
  /// merged corpus rather than only the drafts means the exported file can
  /// replace the asset wholesale, which is far harder to get wrong than a patch.
  String exportJson() {
    final merged = <String, ScanAnnotation>{..._bundled, ..._draft};
    return _encode(merged, pretty: true);
  }

  static String _encode(Map<String, ScanAnnotation> m, {bool pretty = false}) {
    final keys = m.keys.toList()..sort();
    final doc = {
      r'$comment': [
        'Structure letters and presentation crops, per ultrasound scan.',
        'Coordinates are SOURCE IMAGE PIXELS. crop is [x, y, w, h] or absent for the full frame.',
        'Authored in the app (muscle page -> Label & crop) and committed with tools/pull_annotations.py.',
      ],
      'scans': {for (final k in keys) k: m[k]!.toJson()},
    };
    return pretty
        ? const JsonEncoder.withIndent('  ').convert(doc)
        : json.encode(doc);
  }
}
