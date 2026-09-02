import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/session_planner.dart';
import 'package:neuroinject/models/session_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The live session is used mid-procedure, so the things pinned here are the
/// ones whose failure would matter with a needle in hand: what counts toward
/// the delivered total, what a skip means, and whether progress survives the
/// app being killed.
SessionItem _item(String id, {double dose = 50, String brand = 'Botox'}) =>
    SessionItem(
      muscleId: id,
      muscleName: id.toUpperCase(),
      group: 'Upper Extremity',
      brand: brand,
      dose: dose,
    );

Future<SessionPlanner> _loaded() async {
  final p = SessionPlanner();
  // The constructor loads asynchronously; let it settle before asserting.
  await Future<void>.delayed(const Duration(milliseconds: 20));
  return p;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a session will not start with an empty plan', () async {
    final p = await _loaded();
    p.startSession();
    expect(p.isRunning, isFalse);
  });

  test('focus is the first unfinished muscle, in plan order', () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b'), _item('c')]);
    p.startSession();
    expect(p.current?.muscleId, 'a');
    p.finishMuscle('a');
    expect(p.current?.muscleId, 'b');
  });

  test('delivered counts only finished muscles that had a site logged',
      () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b'), _item('c')]);
    p.startSession();

    // Logged but not finished: nothing delivered yet.
    p.logSite('a');
    expect(p.deliveredTotals['Botox'] ?? 0, 0);

    p.finishMuscle('a');
    expect(p.deliveredTotals['Botox'], 50);

    // Finished with no sites is a skip and must contribute nothing — the
    // whole point of separating delivered from planned.
    p.finishMuscle('b');
    expect(p.completed.firstWhere((i) => i.muscleId == 'b').wasSkipped, isTrue);
    expect(p.deliveredTotals['Botox'], 50);
    expect(p.brandTotals['Botox'], 150, reason: 'planned is unchanged');
  });

  test('bilateral doubles the delivered units, as it does the planned',
      () async {
    final p = await _loaded();
    p.addAll([_item('a')]);
    p.setSide('a', InjectionSide.bilateral);
    p.startSession();
    p.logSite('a');
    p.finishMuscle('a');
    expect(p.deliveredTotals['Botox'], 100);
  });

  test('undo cannot drive the site count below zero', () async {
    final p = await _loaded();
    p.addAll([_item('a')]);
    p.undoSite('a');
    p.undoSite('a');
    expect(p.itemFor('a')!.sitesLogged, 0);
  });

  test('reopening a muscle puts it back in the queue with its sites',
      () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b')]);
    p.startSession();
    p.logSite('a');
    p.logSite('a');
    p.finishMuscle('a');
    expect(p.current?.muscleId, 'b');

    p.reopenMuscle('a');
    expect(p.current?.muscleId, 'a', reason: 'back to the front of the queue');
    expect(p.itemFor('a')!.sitesLogged, 2, reason: 'sites are not lost');
  });

  test('ending clears progress and the clock but keeps the plan', () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b')]);
    p.startSession();
    p.logSite('a');
    p.finishMuscle('a');

    p.endSession();
    expect(p.isRunning, isFalse);
    expect(p.count, 2, reason: 'the plan is reusable next visit');
    expect(p.completed, isEmpty);
    expect(p.itemFor('a')!.sitesLogged, 0);
    expect(p.deliveredTotals, isEmpty);
  });

  test('progress survives the app being killed mid-procedure', () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b')]);
    p.startSession();
    p.logSite('a');
    p.logSite('a');
    p.finishMuscle('a');
    p.logSite('b');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // A fresh planner over the same storage is what a relaunch looks like.
    final revived = await _loaded();
    expect(revived.isRunning, isTrue, reason: 'the clock keeps running');
    expect(revived.completed.map((i) => i.muscleId), ['a']);
    expect(revived.itemFor('b')!.sitesLogged, 1);
    expect(revived.current?.muscleId, 'b');
    expect(revived.deliveredTotals['Botox'], 50);
  });

  test('a plan saved before live sessions existed loads as not started',
      () async {
    SharedPreferences.setMockInitialValues({
      'session_plan_v1':
          '[{"muscleId":"a","muscleName":"A","group":"Upper Extremity",'
              '"brand":"Botox","dose":50,"side":"right"}]',
    });
    final p = await _loaded();
    expect(p.count, 1);
    expect(p.isRunning, isFalse);
    expect(p.itemFor('a')!.sitesLogged, 0);
    expect(p.itemFor('a')!.isDone, isFalse);
  });

  // ── the data-loss paths found in review ───────────────────────

  test('re-adding a muscle mid-session keeps its progress', () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b')]);
    p.startSession();
    p.logSite('a');
    p.logSite('a');
    p.finishMuscle('a');

    // Adding a pattern that overlaps the plan replaces the line's dose and
    // brand — it must not zero the sites or un-finish the muscle.
    p.addAll([_item('a', dose: 80), _item('c')]);
    final a = p.itemFor('a')!;
    expect(a.dose, 80, reason: 'the new dose is taken');
    expect(a.sitesLogged, 2, reason: 'sites survive the replacement');
    expect(a.isDone, isTrue, reason: 'completion survives the replacement');
    expect(p.current?.muscleId, 'b', reason: 'a stays finished');

    p.addOrUpdate(_item('b', dose: 60));
    p.logSite('b');
    p.addOrUpdate(_item('b', dose: 70));
    expect(p.itemFor('b')!.sitesLogged, 1);
  });

  test('clearing the plan ends the session too', () async {
    final p = await _loaded();
    p.addAll([_item('a')]);
    p.startSession();
    expect(p.isRunning, isTrue);

    p.clear();
    expect(p.isRunning, isFalse,
        reason: 'the clock must not keep running against an empty plan');
    expect(p.elapsed, Duration.zero);

    // A plan added afterwards is a fresh one, not a resumption.
    p.addAll([_item('b')]);
    expect(p.isRunning, isFalse);
  });

  test('loading a saved session ends the running one and starts clean',
      () async {
    final p = await _loaded();
    p.addAll([_item('a'), _item('b')]);
    p.saveCurrentAs('visit');
    p.startSession();
    p.logSite('a');
    p.finishMuscle('a');
    // Snapshot taken again WITH progress, to prove it is stripped on load.
    p.saveCurrentAs('visit-with-progress');

    p.loadSaved('visit-with-progress');
    expect(p.isRunning, isFalse);
    expect(p.completed, isEmpty);
    expect(p.itemFor('a')!.sitesLogged, 0);
    expect(p.count, 2, reason: 'the lines themselves are loaded');
  });
}
