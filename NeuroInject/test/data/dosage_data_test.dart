import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/muscle.dart';
import 'package:neuroinject/models/session_item.dart';

/// Data-integrity guards for the per-brand dose strings in muscles.json.
///
/// The session planner and the muscle-detail "open in calculator" link seed a
/// numeric dose by feeding each range string through [midpointOfDoseRange],
/// which parses the FIRST TWO numbers it finds. A composite string like
/// "1.25-2.5 per site (7.5-15 total per eye)" would silently parse to the
/// per-site pair (midpoint ~2) and badly under-represent the real dose, so we
/// pin the invariant that every dose string is a clean numeric range.
void main() {
  final muscles = (json.decode(
              File('assets/data/muscles.json').readAsStringSync()) as List)
      .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
      .toList();

  // A bare number or hyphenated range, optionally with a trailing " U" unit.
  final cleanRange = RegExp(r'^\d+(\.\d+)?(\s*-\s*\d+(\.\d+)?)?(\s*U)?$');

  String? brandValue(Dosage d, String brand) => switch (brand) {
        'botox' => d.botox,
        'xeomin' => d.xeomin,
        'dysport' => d.dysport,
        _ => null,
      };

  test('loads the full muscle set', () {
    expect(muscles.length, greaterThan(60));
  });

  group('dose strings are clean numeric ranges', () {
    for (final m in muscles) {
      final d = m.dosage;
      if (d == null) continue;
      for (final brand in ['botox', 'xeomin', 'dysport']) {
        final v = brandValue(d, brand);
        if (v == null) continue;
        test('${m.id} · $brand ("$v")', () {
          expect(cleanRange.hasMatch(v), isTrue,
              reason: '"$v" is not a clean range — the dose parser only reads '
                  'the first two numbers, so any "per site"/parenthetical text '
                  'would be silently dropped. Encode the intended total range.');
          // The midpoint must come from THIS string's numbers, never null.
          expect(midpointOfDoseRange(v), isNotNull);
        });
      }
    }
  });

  test('Dysport is consistently ~2.5-3x Botox where both are given', () {
    // Internal-consistency guard: Botox and Dysport units are not 1:1.
    final offenders = <String>[];
    for (final m in muscles) {
      final d = m.dosage;
      if (d?.botox == null || d?.dysport == null) continue;
      final b = midpointOfDoseRange(d!.botox!);
      final dy = midpointOfDoseRange(d.dysport!);
      if (b == null || dy == null || b == 0) continue;
      final ratio = dy / b;
      if (ratio < 1.8 || ratio > 3.8) offenders.add('${m.id}: ${ratio.toStringAsFixed(1)}x');
    }
    expect(offenders, isEmpty,
        reason: 'Dysport:Botox ratio outside 1.8-3.8x: ${offenders.join(', ')}');
  });
}
