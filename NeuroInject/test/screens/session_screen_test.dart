import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/muscle_provider.dart';
import 'package:neuroinject/data/session_planner.dart';
import 'package:neuroinject/models/session_item.dart';
import 'package:neuroinject/screens/session/session_screen.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Widget host(SessionPlanner planner) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MuscleDataProvider()),
          ChangeNotifierProvider<SessionPlanner>.value(value: planner),
        ],
        child: const MaterialApp(home: SessionScreen()),
      );

  testWidgets('shows the empty state when the plan has no muscles',
      (tester) async {
    await tester.pumpWidget(host(SessionPlanner()));
    expect(find.text('No muscles in this session yet'), findsOneWidget);
  });

  testWidgets('renders an item row and its brand ceiling meter',
      (tester) async {
    final planner = SessionPlanner();
    planner.addOrUpdate(const SessionItem(
      muscleId: 'fcr',
      muscleName: 'Flexor Carpi Radialis',
      group: 'Upper Extremity',
      brand: 'Botox',
      dose: 50,
    ));

    await tester.pumpWidget(host(planner));

    // Item row
    expect(find.text('Flexor Carpi Radialis'), findsOneWidget);
    // Brand ceiling meter header (uppercased) + the labeled total / max
    expect(find.text('BOTOX'), findsOneWidget);
    expect(find.text('50 / 400 U'), findsOneWidget);
  });
}
