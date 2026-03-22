import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/muscle.dart';

class MuscleData {
  static List<Muscle>? _cache;

  static Future<List<Muscle>> load() async {
    if (_cache != null) return _cache!;
    final jsonString = await rootBundle.loadString('assets/data/muscles.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final muscles = <Muscle>[];
    for (final item in jsonList) {
      try {
        muscles.add(Muscle.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        // Skip malformed entries so one bad record doesn't break the whole list
        debugPrint('Skipping malformed muscle entry: $e');
      }
    }
    _cache = muscles;
    return _cache!;
  }
}
