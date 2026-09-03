import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/us_annotation_store.dart';
import 'package:neuroinject/models/structure_kind.dart';
import 'package:neuroinject/models/us_annotation.dart';
import 'package:neuroinject/screens/highlight/scan_annotator_screen.dart';

/// The author loop, driven end to end: tap the scan, name the structure, and
/// the letter is in the store keyed by the SCAN — which is what makes it show
/// up for every muscle that shares the view.
///
/// The screen decodes a real bundled scan, so this exercises the actual
/// coordinate mapping rather than a stub: a tap lands somewhere specific in
/// source pixels, and the assertion is that it landed inside the real frame.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// SegmentedButton draws a check on its selected segment, so the save action
  /// has to be addressed through the app bar rather than by icon alone.
  final saveAction = find.descendant(
      of: find.byType(AppBar), matching: find.byIcon(Icons.check));

  const scan = 'assets/images/clinical/us-gastrocnemius-medial-soleus.jpg';
  const mask = 'assets/images/us_reference/gastrocnemius-medial-us.mask.png';

  late UsAnnotationStore store;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    store = UsAnnotationStore(autoLoad: false);
  });

  /// The screen decodes a real bundled JPEG, which only progresses in a true
  /// async zone — so the pump runs under runAsync and the assertions do not.
  Future<void> pump(WidgetTester tester) async {
    // The scan panel is a 4:3 AspectRatio, so on the default 800x600 surface
    // the crop controls and the key fall below the fold of a lazy ListView and
    // are never built. Give the test room rather than scrolling for each one.
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await tester.pumpWidget(ChangeNotifierProvider<UsAnnotationStore>.value(
        value: store,
        child: const MaterialApp(
          home: ScanAnnotatorScreen(
            scanAsset: scan,
            maskAsset: mask,
            accent: Color(0xFF3E9BE0),
            title: 'Gastrocnemius (Medial)',
          ),
        ),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
  }

  testWidgets('tapping the scan letters a structure, and it reaches the store',
      (tester) async {
    await pump(tester);

    // Tap inside the image to place the first letter.
    final canvas = find.byType(AspectRatio).first;
    expect(canvas, findsOneWidget);
    await tester.tap(canvas);
    await tester.pumpAndSettle();

    // The editor opens with the auto-assigned letter and a name field.
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Soleus');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Rendered in the key beneath the image.
    expect(find.text('Soleus'), findsWidgets);

    // Saving hands it to the store under the SCAN's name.
    await tester.tap(saveAction);
    await tester.pumpAndSettle();

    final saved = store.forScan(scan);
    expect(saved.labels, hasLength(1));
    expect(saved.labels.single.name, 'Soleus');
    expect(saved.labels.single.letter, 'A');

    // The tap must map into the real frame, not to some clamped corner.
    final p = saved.labels.single.point;
    expect(p.dx, inInclusiveRange(0, 960));
    expect(p.dy, inInclusiveRange(0, 720));

    // Keyed by file name, so a muscle sharing this view resolves the same
    // annotation even though it reaches it from its own record.
    expect(
        UsAnnotationStore.keyFor(scan), 'us-gastrocnemius-medial-soleus.jpg');
  });

  testWidgets('Full frame clears the crop and leaves the letters alone',
      (tester) async {
    await store.put(
        scan,
        const ScanAnnotation(
          crop: Rect.fromLTWH(60, 30, 840, 660),
          labels: [
            StructureLabel(
                letter: 'A',
                name: 'Soleus',
                kind: StructureKind.muscle,
                point: Offset(500, 470)),
          ],
        ));
    await pump(tester);

    await tester.tap(find.text('Crop'));
    await tester.pumpAndSettle();

    final reset = find.widgetWithText(OutlinedButton, 'Full frame');
    expect(tester.widget<OutlinedButton>(reset).onPressed, isNotNull,
        reason: 'a crop is set, so the reset is live');

    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(saveAction);
    await tester.pumpAndSettle();

    // Crop cleared, letters untouched — they are independent concerns.
    final saved = store.forScan(scan);
    expect(saved.crop, isNull);
    expect(saved.labels, hasLength(1));
  });

  test('an empty annotation drops the draft rather than storing nothing',
      () async {
    final s = UsAnnotationStore(autoLoad: false);
    await s.put(scan, const ScanAnnotation());
    expect(s.isDraft(scan), isFalse);

    await s.put(
        scan,
        const ScanAnnotation(labels: [
          StructureLabel(
              letter: 'A',
              name: 'Soleus',
              kind: StructureKind.muscle,
              point: Offset(1, 2))
        ]));
    expect(s.isDraft(scan), isTrue);

    // The export is the whole corpus in the asset's shape, so it can replace
    // the file wholesale rather than being merged by hand.
    expect(s.exportJson(), contains('us-gastrocnemius-medial-soleus.jpg'));
    expect(s.exportJson(), contains('"letter": "A"'));
  });
}
