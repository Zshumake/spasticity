import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight_capture.dart';

/// Local store of accepted [HighlightCapture]s — the growing, self-generated
/// training set behind the draw-to-highlight feature.
///
/// SCAFFOLD STORAGE: persists JSON in shared_preferences. This is fine now
/// because a capture only references a BUNDLED asset path plus a polygon (no
/// patient data). Before the app stores captured *live* US frames (PHI), this
/// must move to an encrypted on-device store (SQLCipher / AES-256) — see the
/// research brief's data-pipeline section. The public API here stays the same.
class HighlightCaptureStore extends ChangeNotifier {
  static const String _key = 'highlight_captures_v1';
  final List<HighlightCapture> _items = [];

  HighlightCaptureStore() {
    _load();
  }

  int get count => _items.length;
  List<HighlightCapture> get all => List.unmodifiable(_items);
  int countFor(String muscleId) =>
      _items.where((c) => c.muscleId == muscleId).length;

  Future<void> add(HighlightCapture capture) async {
    _items.add(capture);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    final before = _items.length;
    _items.removeWhere((c) => c.id == id);
    if (_items.length == before) return;
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, json.encode([for (final c in _items) c.toJson()]));
    } catch (e) {
      debugPrint('Error saving highlight captures: $e');
    }
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      _items
        ..clear()
        ..addAll([
          for (final e in json.decode(raw) as List)
            HighlightCapture.fromJson(e as Map<String, dynamic>)
        ]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading highlight captures: $e');
    }
  }
}
