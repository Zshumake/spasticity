import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/muscle.dart';
import '../models/spasticity_pattern.dart';

class MuscleData {
  static List<Muscle>? _muscleCache;
  static List<SpasticityPattern>? _patternCache;

  static Future<List<Muscle>> load() async {
    if (_muscleCache != null) return _muscleCache!;
    final jsonString = await rootBundle.loadString('assets/data/muscles.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final muscles = <Muscle>[];
    for (final item in jsonList) {
      try {
        muscles.add(Muscle.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skipping malformed muscle entry: $e');
      }
    }
    _muscleCache = muscles;
    return _muscleCache!;
  }

  static Future<List<SpasticityPattern>> loadPatterns() async {
    if (_patternCache != null) return _patternCache!;
    final jsonString = await rootBundle.loadString('assets/data/patterns.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final patterns = <SpasticityPattern>[];
    for (final item in jsonList) {
      try {
        patterns.add(SpasticityPattern.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skipping malformed pattern entry: $e');
      }
    }
    _patternCache = patterns;
    return _patternCache!;
  }

  /// Get muscles for a specific pattern
  static Future<List<Muscle>> musclesForPattern(String patternId) async {
    final muscles = await load();
    final patterns = await loadPatterns();
    final pattern = patterns.where((p) => p.id == patternId).firstOrNull;
    if (pattern == null) return [];
    return muscles.where((m) => pattern.muscles.contains(m.id)).toList();
  }

  /// Find muscle by ID
  static Future<Muscle?> findById(String id) async {
    final muscles = await load();
    return muscles.where((m) => m.id == id).firstOrNull;
  }
}
