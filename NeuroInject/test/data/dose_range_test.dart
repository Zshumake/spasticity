import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/dose_range.dart';
import 'package:neuroinject/models/muscle.dart';

/// The planner turns display strings into arithmetic against a session
/// ceiling. A range parsed wrong is a total reported wrong, so the parse is
/// pinned here rather than trusted.
void main() {
  group('DoseRange.parse', () {
    test('reads a plain range', () {
      final r = DoseRange.parse('50-100')!;
      expect(r.low, 50);
      expect(r.high, 100);
      expect(r.seed, 50, reason: 'seeds the bottom of the range');
      expect(r.label, '50–100');
    });

    test('tolerates spaces around the dash', () {
      expect(DoseRange.parse('50 - 100')!.high, 100);
    });

    test('reads a single value as a degenerate range', () {
      final r = DoseRange.parse('75')!;
      expect(r.low, 75);
      expect(r.high, 75);
      expect(r.isSingle, isTrue);
      expect(r.label, '75');
    });

    test('orders a reversed range rather than producing a negative span', () {
      final r = DoseRange.parse('100-50')!;
      expect(r.low, 50);
      expect(r.high, 100);
    });

    test('refuses anything it cannot read, rather than guessing', () {
      for (final bad in ['', '  ', 'lots', '50 units', '50-', '-50', '1-2-3']) {
        expect(DoseRange.parse(bad), isNull, reason: 'should refuse "$bad"');
      }
      expect(DoseRange.parse(null), isNull);
    });

    test('keeps decimals out of integer labels', () {
      expect(DoseRange.parse('12.5')!.label, '12.5');
      expect(DoseRange.parse('20')!.label, '20');
    });
  });

  group('DoseRange.forBrand', () {
    const d = Dosage(botox: '50-100', xeomin: '50-100', dysport: '150-300');

    test('picks the range for the named brand', () {
      expect(DoseRange.forBrand(d, 'Botox')!.seed, 50);
      expect(DoseRange.forBrand(d, 'Dysport')!.seed, 150);
    });

    test('a brand with no documented dose is null, not zero', () {
      // Zero would silently understate a session total; null drops the muscle
      // out of the plan visibly instead.
      expect(DoseRange.forBrand(const Dosage(botox: '50'), 'Dysport'), isNull);
      expect(DoseRange.forBrand(null, 'Botox'), isNull);
      expect(DoseRange.forBrand(d, 'Myobloc'), isNull);
    });
  });
}
