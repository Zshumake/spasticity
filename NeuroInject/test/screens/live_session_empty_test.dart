import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/session_planner.dart';
import 'package:neuroinject/screens/session/live_session_screen.dart';

/// The live screen with nothing planned used to say "Every muscle accounted
/// for" — technically true of an empty list, and exactly wrong as a message.
/// It is only reachable by opening the route directly or clearing the plan
/// while the screen is up, so it gets a test rather than a manual check.
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Widget host(SessionPlanner planner, {Brightness brightness = Brightness.dark}) =>
      ChangeNotifierProvider<SessionPlanner>.value(
        value: planner,
        child: MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const LiveSessionScreen(),
        ),
      );

  testWidgets('an empty plan says so, not "every muscle accounted for"',
      (tester) async {
    final planner = SessionPlanner();
    await tester.pumpWidget(host(planner));
    await tester.pump();

    expect(find.text('Nothing planned yet'), findsOneWidget);
    expect(find.text('Every muscle accounted for'), findsNothing);
    expect(find.text('BACK TO THE PLAN'), findsOneWidget);
  });

  testWidgets('the empty state renders in the light theme without dark chrome',
      (tester) async {
    final planner = SessionPlanner();
    await tester.pumpWidget(host(planner, brightness: Brightness.light));
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    // bgLight is #EFF2F6; anything darker than mid-grey means the screen is
    // still painting its old hardcoded dark background under a light app.
    final bg = scaffold.backgroundColor!;
    expect(bg.computeLuminance(), greaterThan(0.5),
        reason: 'live session must follow the light theme');
  });

  testWidgets('every control is announced as a button', (tester) async {
    // Semantics must be switched on BEFORE the frame is pumped; enabling it
    // afterwards leaves no tree to search and the finder reports nothing.
    final handle = tester.ensureSemantics();
    final planner = SessionPlanner();
    await tester.pumpWidget(host(planner));
    await tester.pump();

    // The button's own label is merged with its visible text, so match on
    // the label rather than requiring equality with the whole merged string.
    expect(
      find.bySemanticsLabel(RegExp('Go to the session plan')),
      findsOneWidget,
      reason: 'the one control on this state must carry a label',
    );
    final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Go to the session plan')));
    expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
    handle.dispose();
  });
}
