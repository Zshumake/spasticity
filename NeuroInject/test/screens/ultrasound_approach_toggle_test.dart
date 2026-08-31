import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/muscle_provider.dart';
import 'package:neuroinject/data/session_planner.dart';
import 'package:neuroinject/models/muscle.dart';
import 'package:neuroinject/screens/guide/muscle_detail.dart';
import 'package:neuroinject/theme/favorites_manager.dart';
import 'package:neuroinject/theme/recently_viewed_manager.dart';

/// The approach toggle is what keeps a multi-window muscle honest: the probe
/// illustration and the scan must always describe the SAME transducer
/// placement. Tibialis posterior shipped mismatched for a while (medial probe
/// photo beside the anterior scan), so this pins the behaviour down.
///
/// NOTE: muscles.json is loaded in setUpAll, NOT inside testWidgets. A real
/// async asset load never completes inside testWidgets' fake-async zone — it
/// hangs until the 10-minute timeout rather than failing.
void main() {
  late List<Muscle> muscles;
  late MuscleDataProvider data;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString('assets/data/muscles.json');
    muscles = [
      for (final m in json.decode(raw) as List)
        Muscle.fromJson(m as Map<String, dynamic>)
    ];
    // Built once and shared via .value: MuscleDataProvider loads muscles.json
    // asynchronously in its constructor, and a per-test instance gets disposed
    // while that load is still in flight, tripping a notify-after-dispose
    // assert that has nothing to do with what these tests check.
    data = MuscleDataProvider();
  });

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Muscle byId(String id) => muscles.firstWhere((m) => m.id == id);

  Widget host(Muscle m) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MuscleDataProvider>.value(value: data),
          ChangeNotifierProvider(create: (_) => FavoritesManager()),
          ChangeNotifierProvider(create: (_) => RecentlyViewedManager()),
          ChangeNotifierProvider(create: (_) => SessionPlanner()),
        ],
        child: MaterialApp(home: MuscleDetailScreen(muscle: m)),
      );

  /// Plain pumps only — never tester.runAsync here. runAsync lets
  /// google_fonts' real runtime fetch proceed, which throws because
  /// allowRuntimeFetching is off and the fonts are not bundled as assets.
  Future<void> show(WidgetTester tester, Muscle m) async {
    await tester.pumpWidget(host(m));
    await tester.pump();
  }

  testWidgets('a two-window muscle offers a chip per approach',
      (tester) async {
    await show(tester, byId('tibialis-posterior'));

    expect(find.text('ANTERIOR APPROACH'), findsOneWidget);
    expect(find.text('MEDIAL APPROACH'), findsOneWidget);
  });

  testWidgets('a single-window muscle shows no toggle at all', (tester) async {
    final biceps = byId('biceps-brachii');
    expect(biceps.resolvedUltrasoundViews, hasLength(1));

    await show(tester, biceps);

    expect(find.text('ANTERIOR APPROACH'), findsNothing);
    expect(find.text('MEDIAL APPROACH'), findsNothing);
  });

  test('the two approaches never share a scan, mask or probe picture', () {
    final [anterior, medial] = byId('tibialis-posterior').resolvedUltrasoundViews;
    expect(anterior.scanAsset, isNot(medial.scanAsset));
    expect(anterior.probeAsset, isNot(medial.probeAsset));
    expect(anterior.maskAsset, isNot(medial.maskAsset));
  });
}
