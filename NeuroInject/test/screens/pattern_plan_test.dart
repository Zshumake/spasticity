import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/muscle_provider.dart';
import 'package:neuroinject/data/session_planner.dart';
import 'package:neuroinject/screens/plan/pattern_plan_screen.dart';

/// The planner turns a pattern into session lines. What it must never do is
/// put a number the app invented next to a muscle: dose recommendations were
/// withdrawn from the corpus, so a line reaches the session at 0 U for the
/// injector to enter.
///
/// The screen and the provider both read assets asynchronously, which is why
/// every pump here runs under runAsync — the fonts are bundled, so the
/// google_fonts runtime-fetch trap that ruled runAsync out before no longer
/// applies.
void main() {
  late MuscleDataProvider data;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    data = MuscleDataProvider();
    // Let the constructor's asset load settle in a real async zone.
    while (!data.isLoaded) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<SessionPlanner> pumpPlanner(WidgetTester tester, String pattern) async {
    final planner = SessionPlanner();
    // The screen navigates with context.push('/session'), so it needs a router.
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, _) => PatternPlanScreen(patternId: pattern)),
      GoRoute(path: '/session', builder: (_, _) => const Scaffold()),
    ]);
    await tester.runAsync(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<MuscleDataProvider>.value(value: data),
          ChangeNotifierProvider<SessionPlanner>.value(value: planner),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      // patterns.json is read in initState; give it a real tick.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    return planner;
  }

  testWidgets('lists the pattern’s visible muscles with nothing selected',
      (tester) async {
    await pumpPlanner(tester, 'cervical-dystonia');

    expect(find.text('CANDIDATE MUSCLES'), findsOneWidget);
    expect(find.text('0 OF 6'), findsOneWidget,
        reason: 'six torticollis muscles have an ultrasound; none pre-ticked');
    expect(find.text('SELECT MUSCLES TO PLAN'), findsOneWidget);
    // No dose is shown anywhere on the planner.
    expect(find.textContaining(' U'), findsNothing);
  });

  testWidgets('ticking muscles updates the count and the call to action',
      (tester) async {
    await pumpPlanner(tester, 'cervical-dystonia');

    await tester.tap(find.text('Sternocleidomastoid (SCM)'));
    await tester.pump();
    await tester.tap(find.text('Splenius Capitis'));
    await tester.pump();

    expect(find.text('2 OF 6'), findsOneWidget);
    expect(find.text('ADD 2 TO SESSION'), findsOneWidget);

    // Ticking again un-ticks.
    await tester.tap(find.text('Splenius Capitis'));
    await tester.pump();
    expect(find.text('1 OF 6'), findsOneWidget);
  });

  testWidgets('adding to the session creates doseless lines', (tester) async {
    final planner = await pumpPlanner(tester, 'cervical-dystonia');

    await tester.tap(find.text('Sternocleidomastoid (SCM)'));
    await tester.pump();
    await tester.tap(find.text('ADD 1 TO SESSION'));
    await tester.pump();

    expect(planner.count, 1);
    final line = planner.items.single;
    expect(line.muscleId, 'scm');
    expect(line.dose, 0, reason: 'the app must not invent a dose');
    expect(line.brand, 'Botox', reason: 'the default brand, not a corpus pick');
  });

  testWidgets('every row and the action are announced', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPlanner(tester, 'cervical-dystonia');

    final row = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Sternocleidomastoid')));
    expect(row.flagsCollection.isButton, isTrue);
    expect(row.flagsCollection.isChecked, isNot(CheckedState.none));

    expect(find.bySemanticsLabel(RegExp('Select muscles to plan')),
        findsOneWidget);
    handle.dispose();
  });
}
