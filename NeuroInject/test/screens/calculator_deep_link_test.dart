import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroinject/screens/calculator/calculator_screen.dart';

// The brand info card renders the selected brand's maxDoseNote verbatim, so a
// brand-specific substring is a reliable signal for which brand is selected.
const _dysportSignal = 'lower limb spasticity'; // Dysport maxDoseNote
const _botoxSignal = '400 U for spasticity'; // Botox maxDoseNote

void main() {
  setUp(() {
    // Keep the tests hermetic: no network font fetches.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('seeds brand and dose from deep-link parameters', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CalculatorScreen(initialBrand: 'Dysport', initialDose: 450),
    ));
    await tester.pump();

    // Dose field seeded to the passed value (would be 50 if seeding failed).
    expect(find.text('450'), findsWidgets);
    // Brand seeded to Dysport (its max-dose note is showing).
    expect(find.textContaining(_dysportSignal), findsWidgets);
  });

  testWidgets('brand match is case-insensitive', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CalculatorScreen(initialBrand: 'dysport', initialDose: 300),
    ));
    await tester.pump();

    expect(find.text('300'), findsWidgets);
    expect(find.textContaining(_dysportSignal), findsWidgets);
  });

  testWidgets('falls back to defaults when no parameters are given',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
    await tester.pump();

    // Default Botox dose (50) and Botox max-dose note.
    expect(find.text('50'), findsWidgets);
    expect(find.textContaining(_botoxSignal), findsWidgets);
  });

  testWidgets('unknown brand name falls back to the default brand',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CalculatorScreen(initialBrand: 'Nonsense', initialDose: 70),
    ));
    await tester.pump();

    // Dose still applied; brand stays Botox (its max-dose note is showing).
    expect(find.text('70'), findsWidgets);
    expect(find.textContaining(_botoxSignal), findsWidgets);
  });
}
