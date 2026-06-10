import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/session_planner.dart';
import 'package:neuroinject/models/muscle.dart';
import 'package:neuroinject/models/session_item.dart';

void main() {
  setUp(() {
    // SessionPlanner persists via shared_preferences on every mutation.
    SharedPreferences.setMockInitialValues({});
  });

  SessionItem item(String id, String brand, double dose,
          [InjectionSide side = InjectionSide.right]) =>
      SessionItem(
          muscleId: id,
          muscleName: id,
          group: 'Upper Extremity',
          brand: brand,
          dose: dose,
          side: side);

  group('SessionItem', () {
    test('bilateral doubles the dose toward the total', () {
      expect(item('a', 'Botox', 50).totalUnits, 50);
      expect(item('a', 'Botox', 50, InjectionSide.left).totalUnits, 50);
      expect(item('a', 'Botox', 50, InjectionSide.bilateral).totalUnits, 100);
    });

    test('round-trips through JSON', () {
      final restored = SessionItem.fromJson(
          item('fcr', 'Dysport', 250, InjectionSide.bilateral).toJson());
      expect(restored.muscleId, 'fcr');
      expect(restored.brand, 'Dysport');
      expect(restored.dose, 250);
      expect(restored.side, InjectionSide.bilateral);
      expect(restored.totalUnits, 500);
    });
  });

  group('SessionPlanner', () {
    test('addOrUpdate adds new muscles and replaces by id (no duplicates)', () {
      final p = SessionPlanner();
      p.addOrUpdate(item('a', 'Botox', 50));
      p.addOrUpdate(item('b', 'Botox', 30));
      expect(p.count, 2);

      p.addOrUpdate(item('a', 'Botox', 80));
      expect(p.count, 2);
      expect(p.itemFor('a')!.dose, 80);
    });

    test('brandTotals sums per brand, doubling bilateral lines', () {
      final p = SessionPlanner();
      p.addOrUpdate(item('a', 'Botox', 50)); // 50
      p.addOrUpdate(item('b', 'Botox', 50, InjectionSide.bilateral)); // 100
      p.addOrUpdate(item('c', 'Dysport', 250)); // 250
      expect(p.brandTotals['Botox'], 150);
      expect(p.brandTotals['Dysport'], 250);
    });

    test('setDose / setSide / setBrand mutate the right item', () {
      final p = SessionPlanner();
      p.addOrUpdate(item('a', 'Botox', 50));

      p.setDose('a', 75);
      expect(p.itemFor('a')!.dose, 75);

      p.setSide('a', InjectionSide.bilateral);
      expect(p.itemFor('a')!.totalUnits, 150);

      p.setBrand('a', 'Dysport', 250);
      expect(p.itemFor('a')!.brand, 'Dysport');
      expect(p.itemFor('a')!.dose, 250);
    });

    test('setDose floors at zero', () {
      final p = SessionPlanner();
      p.addOrUpdate(item('a', 'Botox', 5));
      p.setDose('a', -10);
      expect(p.itemFor('a')!.dose, 0);
    });

    test('remove and clear', () {
      final p = SessionPlanner();
      p.addOrUpdate(item('a', 'Botox', 50));
      p.addOrUpdate(item('b', 'Botox', 50));

      p.remove('a');
      expect(p.contains('a'), false);
      expect(p.count, 1);

      p.clear();
      expect(p.isEmpty, true);
    });
  });

  group('seeding helpers', () {
    Muscle muscleWith(Map<String, dynamic> dosage) => Muscle(
          id: 'x',
          name: 'X',
          group: 'Upper Extremity',
          pattern: 'p',
          landmarks: const [],
          placement: const [],
          setup: const [],
          dosage: Dosage.tryParse(dosage),
        );

    test('availableBrandsFor lists only brands with a dose, in order', () {
      expect(
          availableBrandsFor(
              muscleWith({'botox': '50-100', 'dysport': '150-300'})),
          ['Botox', 'Dysport']);
      expect(availableBrandsFor(muscleWith({'xeomin': '50-100'})), ['Xeomin']);
      expect(availableBrandsFor(muscleWith({})), isEmpty);
    });

    test('doseForBrand returns the range midpoint', () {
      final m = muscleWith({'botox': '100-200', 'dysport': '300'});
      expect(doseForBrand(m, 'Botox'), 150);
      expect(doseForBrand(m, 'Dysport'), 300);
      expect(doseForBrand(m, 'Xeomin'), null);
    });

    test('defaultSessionItem seeds first brand at midpoint, right side', () {
      final seeded = defaultSessionItem(muscleWith({'botox': '100-200'}))!;
      expect(seeded.brand, 'Botox');
      expect(seeded.dose, 150);
      expect(seeded.side, InjectionSide.right);
    });

    test('defaultSessionItem is null when no dose exists', () {
      expect(defaultSessionItem(muscleWith({})), null);
    });
  });
}
