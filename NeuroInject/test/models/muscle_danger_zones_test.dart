import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/muscle.dart';

void main() {
  group('Muscle.dangerZones', () {
    test('defaults to empty list when field absent in JSON', () {
      final json = {
        'id': 'test',
        'name': 'Test Muscle',
        'group': 'Upper Extremity',
        'pattern': 'flexed-elbow',
        'landmarks': <String>[],
        'placement': <String>[],
        'setup': <String>[],
      };
      final muscle = Muscle.fromJson(json);
      expect(muscle.dangerZones, isEmpty);
    });

    test('parses dangerZones from JSON when present', () {
      final json = {
        'id': 'test',
        'name': 'Test Muscle',
        'group': 'Upper Extremity',
        'pattern': 'flexed-elbow',
        'landmarks': <String>[],
        'placement': <String>[],
        'setup': <String>[],
        'dangerZones': [
          'Going too deep risks the soleus.',
          'Going too medial risks the neurovascular bundle.',
        ],
      };
      final muscle = Muscle.fromJson(json);
      expect(muscle.dangerZones, hasLength(2));
      expect(muscle.dangerZones.first, startsWith('Going too deep'));
    });

    test('legacy JSON without dangerZones parses without error', () {
      // Simulates a pre-migration payload: only pearls, no dangerZones.
      final json = {
        'id': 'test',
        'name': 'Test Muscle',
        'group': 'Upper Extremity',
        'pattern': 'flexed-elbow',
        'landmarks': <String>[],
        'placement': <String>[],
        'setup': <String>[],
        'pearls': ['General teaching note'],
      };
      final muscle = Muscle.fromJson(json);
      expect(muscle.dangerZones, isEmpty);
      expect(muscle.pearls, equals(['General teaching note']));
    });

    test('pearls and dangerZones are independent lists', () {
      final json = {
        'id': 'test',
        'name': 'Test Muscle',
        'group': 'Upper Extremity',
        'pattern': 'flexed-elbow',
        'landmarks': <String>[],
        'placement': <String>[],
        'setup': <String>[],
        'pearls': ['Teaching pearl A'],
        'dangerZones': ['Hazard X'],
      };
      final muscle = Muscle.fromJson(json);
      expect(muscle.pearls, equals(['Teaching pearl A']));
      expect(muscle.dangerZones, equals(['Hazard X']));
    });
  });
}
