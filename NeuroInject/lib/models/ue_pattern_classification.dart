/// Jost–Hefter–Reißig–Kollewe–Wissel upper-limb spasticity pattern classification.
///
/// Sourced from the Jost Atlas of Botulinum Toxin Injection (Part 1 p4), which
/// cites the German-Austrian Dysport study. Paraphrased for NeuroInject.
///
/// This is a SECOND-level classification: each of the five patterns combines
/// multiple joint postures that correspond to NeuroInject's existing pattern
/// entries (e.g., Pattern IV covers adducted-shoulder + flexed-elbow +
/// pronated-forearm + flexed-wrist).
///
/// The data lives in `assets/data/ue_pattern_classification.json` and is loaded
/// once on app start via [UePatternClassificationData.load].
library;

import 'dart:convert';
import 'package:flutter/services.dart';

/// Top-level data container for the Jost UE classification file.
class UePatternClassificationData {
  final List<JostPattern> patterns;
  final List<HandType> handTypes;

  const UePatternClassificationData({
    required this.patterns,
    required this.handTypes,
  });

  /// Load from bundled assets.
  static Future<UePatternClassificationData> load() async {
    final raw =
        await rootBundle.loadString('assets/data/ue_pattern_classification.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UePatternClassificationData.fromJson(json);
  }

  factory UePatternClassificationData.fromJson(Map<String, dynamic> json) {
    final patterns = (json['patterns'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(JostPattern.fromJson)
        .toList();
    final handTypes = (json['handTypes'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(HandType.fromJson)
        .toList();
    return UePatternClassificationData(
      patterns: patterns,
      handTypes: handTypes,
    );
  }

  /// Find a pattern by its Roman-numeral classification ("I", "II", ...).
  JostPattern? byClassification(String classification) =>
      patterns.cast<JostPattern?>().firstWhere(
            (p) => p?.classification == classification,
            orElse: () => null,
          );

  /// Find a pattern by its stable id ("jost-pattern-1", ...).
  JostPattern? byId(String id) => patterns.cast<JostPattern?>().firstWhere(
        (p) => p?.id == id,
        orElse: () => null,
      );

  /// Find a hand type by its stable id.
  HandType? handTypeById(String id) => handTypes.cast<HandType?>().firstWhere(
        (h) => h?.id == id,
        orElse: () => null,
      );
}

/// One of the five Jost UE spasticity patterns (I–V).
class JostPattern {
  /// Stable id used in JSON and for lookups. E.g., "jost-pattern-4".
  final String id;

  /// Roman-numeral classification label ("I", "II", "III", "IV", "V").
  final String classification;

  /// Display name — typically "Pattern I", "Pattern II", etc.
  final String name;

  /// Short one-line clinical summary for grid/list rendering.
  final String summary;

  /// Full posture description (sentence form).
  final String postureDescription;

  /// Component postures by joint. Keys: shoulder, elbow, forearm, wrist.
  final Map<String, String> components;

  /// IDs in `patterns.json` that this Jost pattern composes. A resident
  /// picking Pattern IV can fan out into the individual posture patterns.
  final List<String> relatedNeuroInjectPatternIds;

  /// Clinical pearl specific to this pattern (common presentation, distinguishing
  /// feature, treatment nuance).
  final String clinicalNotes;

  const JostPattern({
    required this.id,
    required this.classification,
    required this.name,
    required this.summary,
    required this.postureDescription,
    required this.components,
    required this.relatedNeuroInjectPatternIds,
    required this.clinicalNotes,
  });

  factory JostPattern.fromJson(Map<String, dynamic> json) {
    return JostPattern(
      id: json['id'] as String,
      classification: json['classification'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String,
      postureDescription: json['postureDescription'] as String,
      components: Map<String, String>.from(
        (json['components'] as Map).cast<String, String>(),
      ),
      relatedNeuroInjectPatternIds:
          (json['relatedNeuroInjectPatternIds'] as List? ?? []).cast<String>(),
      clinicalNotes: json['clinicalNotes'] as String? ?? '',
    );
  }
}

/// One of three UE hand types (spastic flexion hand, claw hand, lumbrical hand).
class HandType {
  final String id;
  final String name;
  final String summary;
  final String description;
  final List<String> relatedNeuroInjectPatternIds;
  final List<String> keyMuscleIds;

  const HandType({
    required this.id,
    required this.name,
    required this.summary,
    required this.description,
    required this.relatedNeuroInjectPatternIds,
    required this.keyMuscleIds,
  });

  factory HandType.fromJson(Map<String, dynamic> json) {
    return HandType(
      id: json['id'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String,
      description: json['description'] as String,
      relatedNeuroInjectPatternIds:
          (json['relatedNeuroInjectPatternIds'] as List? ?? []).cast<String>(),
      keyMuscleIds: (json['keyMuscleIds'] as List? ?? []).cast<String>(),
    );
  }
}
