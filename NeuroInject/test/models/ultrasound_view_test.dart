import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/muscle.dart';

Muscle _muscle(Map<String, dynamic> extra) => Muscle.fromJson({
      'id': 'test-muscle',
      'name': 'Test Muscle',
      'group': 'Lower Extremity',
      'pattern': 'test',
      'landmarks': <String>[],
      'placement': <String>[],
      'setup': <String>[],
      ...extra,
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolvedUltrasoundViews', () {
    test('a single-view muscle resolves to its own scan, mask and probe', () {
      final m = _muscle({});
      final views = m.resolvedUltrasoundViews;
      expect(views, hasLength(1));
      expect(views.single.scanAsset,
          'assets/images/clinical/test-muscle-us.jpg');
      expect(views.single.maskAsset,
          'assets/images/us_reference/test-muscle-us.mask.png');
      expect(views.single.probeAsset,
          'assets/images/clinical/test-muscle-probe.jpg');
    });

    test('a shared-scan muscle still resolves through its ultrasoundGroup', () {
      final m = _muscle({'ultrasoundGroup': 'calf'});
      expect(m.resolvedUltrasoundViews.single.scanAsset,
          'assets/images/clinical/us-calf.jpg');
    });

    test('explicit views replace the single scan/mask pair', () {
      final m = _muscle({
        'ultrasoundViews': [
          {
            'label': 'Anterior approach',
            'scan': 'assets/images/clinical/a.jpg',
            'mask': 'assets/images/us_reference/a.mask.png',
            'probe': 'assets/images/clinical/a-probe.jpg',
          },
          {
            'label': 'Medial approach',
            'scan': 'assets/images/clinical/b.jpg',
            'mask': 'assets/images/us_reference/b.mask.png',
            'probe': 'assets/images/clinical/b-probe.jpg',
          },
        ],
      });
      final views = m.resolvedUltrasoundViews;
      expect(views.map((v) => v.label),
          ['Anterior approach', 'Medial approach']);
      // Each approach carries its OWN probe picture: the transducer sits
      // somewhere different, so showing one window's probe next to the
      // other's scan would teach the wrong entry point.
      expect(views[0].probeAsset, isNot(views[1].probeAsset));
      expect(views[0].maskAsset, isNot(views[1].maskAsset));
    });
  });

  group('tibialis posterior in the shipped data', () {
    late Muscle tp;

    setUpAll(() async {
      final raw = await rootBundle.loadString('assets/data/muscles.json');
      final all = [
        for (final m in json.decode(raw) as List)
          Muscle.fromJson(m as Map<String, dynamic>)
      ];
      tp = all.firstWhere((m) => m.id == 'tibialis-posterior');
    });

    test('offers both the anterior and the medial window', () {
      expect(tp.resolvedUltrasoundViews, hasLength(2));
      expect(tp.resolvedUltrasoundViews.map((v) => v.label),
          ['Anterior approach', 'Medial approach']);
    });

    test('each approach pairs a distinct probe photo with its own scan', () {
      final [anterior, medial] = tp.resolvedUltrasoundViews;
      expect(anterior.scanAsset, isNot(medial.scanAsset));
      expect(anterior.probeAsset, isNot(medial.probeAsset));
      // The medial window is the FDL view — the scan the sonographer
      // labelled "FDL AND TIB POST".
      expect(medial.scanAsset, 'assets/images/clinical/fdl-us.jpg');
      expect(medial.probeAsset, 'assets/images/clinical/fdl-probe.jpg');
    });
  });
}
