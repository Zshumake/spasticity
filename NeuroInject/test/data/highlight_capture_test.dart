import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neuroinject/data/highlight_capture_store.dart';
import 'package:neuroinject/models/highlight_capture.dart';

HighlightCapture sample(String muscleId, {int t = 1}) => HighlightCapture(
      id: 'cap_$t',
      muscleId: muscleId,
      imageRef: 'assets/images/clinical/$muscleId-us.jpg',
      polygon: const [Offset(0, 0), Offset(10, 0), Offset(10, 10)],
      canvasSize: const Size(320, 240),
      createdAtMillis: t,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('HighlightCapture round-trips through JSON', () {
    final c = sample('fcr', t: 42);
    final back = HighlightCapture.fromJson(c.toJson());
    expect(back.id, c.id);
    expect(back.muscleId, 'fcr');
    expect(back.imageRef, c.imageRef);
    expect(back.polygon, c.polygon);
    expect(back.canvasSize, const Size(320, 240));
    expect(back.createdAtMillis, 42);
  });

  test('store adds, counts, and counts per muscle', () async {
    final store = HighlightCaptureStore();
    await store.add(sample('fcr', t: 1));
    await store.add(sample('fcr', t: 2));
    await store.add(sample('triceps', t: 3));
    expect(store.count, 3);
    expect(store.countFor('fcr'), 2);
    expect(store.countFor('triceps'), 1);
    expect(store.countFor('biceps-brachii'), 0);
  });

  test('remove deletes one capture by id; clear empties the store', () async {
    final store = HighlightCaptureStore();
    await store.add(sample('fcr', t: 1));
    await store.add(sample('fcr', t: 2));
    await store.add(sample('triceps', t: 3));

    await store.remove('cap_2');
    expect(store.count, 2);
    expect(store.countFor('fcr'), 1);

    await store.remove('does-not-exist'); // no-op
    expect(store.count, 2);

    await store.clear();
    expect(store.count, 0);
  });

  test('captures persist across store instances', () async {
    final a = HighlightCaptureStore();
    await a.add(sample('soleus-medial', t: 7));

    // A fresh store loads what the first one persisted.
    final b = HighlightCaptureStore();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(b.countFor('soleus-medial'), 1);
    expect(b.all.first.polygon.length, 3);
  });
}
