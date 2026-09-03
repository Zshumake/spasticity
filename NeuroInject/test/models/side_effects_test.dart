import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/muscle.dart';

/// sideEffects holds what the TOXIN does; dangerZones and
/// ultrasound.safetyNotes hold what the NEEDLE can hit. Keeping them apart is
/// the point of the field — several muscles' primary clinical risk is a
/// consequence of the toxin working and was in neither needle-hazard layer.
void main() {
  late List<Muscle> muscles;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString('assets/data/muscles.json');
    muscles = [
      for (final m in json.decode(raw) as List)
        Muscle.fromJson(m as Map<String, dynamic>)
    ];
  });

  Muscle byId(String id) => muscles.firstWhere((m) => m.id == id);

  test('defaults to empty when the field is absent', () {
    final m = Muscle.fromJson({
      'id': 'x', 'name': 'X', 'group': 'g', 'pattern': 'p',
      'landmarks': <String>[], 'placement': <String>[], 'setup': <String>[],
    });
    expect(m.sideEffects, isEmpty);
  });

  test('parses the adjudicated side effects from the shipped corpus', () {
    final withEffects = muscles.where((m) => m.sideEffects.isNotEmpty).toList();
    expect(withEffects, hasLength(12));
    expect(
        withEffects.fold<int>(0, (n, m) => n + m.sideEffects.length), equals(13));
  });

  test('SCM carries its dysphagia warning in the toxin layer', () {
    final scm = byId('scm');
    expect(scm.sideEffects.single, contains('Dysphagia'));
  });

  test('SCM states dysphagia in the toxin layer and nowhere else', () {
    // Dysphagia is a toxin effect (spread to the pharyngeal muscles), so it
    // belongs to the consent layer. The needle layers used to repeat it; the
    // one needle-technique clause they carried survives without the word.
    final scm = byId('scm');
    bool mentions(Iterable<String> xs) =>
        xs.any((x) => x.toLowerCase().contains('dysphagia'));
    expect(mentions(scm.sideEffects), isTrue);
    expect(mentions(scm.dangerZones), isFalse);
    expect(mentions(scm.ultrasound?.safetyNotes ?? const []), isFalse);
    expect(scm.dangerZones.any((z) => z.toLowerCase().contains('pharyngeal')),
        isTrue, reason: 'the needle-technique point is kept');
  });

  test('the subclavian artery relationship is stated correctly everywhere', () {
    final scalenes = byId('scalenes');
    final everything = [
      ...scalenes.placement,
      ...scalenes.dangerZones,
      ...scalenes.setup,
      ...?scalenes.ultrasound?.safetyNotes,
    ].join(' ').toLowerCase();
    // The inverted claim put the ARTERY anterior to the anterior scalene; the
    // vein is the anterior vessel. No field may say otherwise.
    expect(everything.contains('subclavian artery passes anterior'), isFalse);
  });

  test('pronator teres no longer describes a medial probe position', () {
    final pt = byId('pronator-teres');
    final everything = [
      pt.probePlacementHint ?? '',
      ...pt.placement,
      ...pt.setup,
      ...?pt.ultrasound?.safetyNotes,
      ...?pt.ultrasound?.viewSteps,
      pt.ultrasound?.orientation ?? '',
    ].join(' ').toLowerCase();
    expect(everything.contains('medial proximal forearm'), isFalse);
  });
}
