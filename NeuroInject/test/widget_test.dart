import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neuroinject/data/muscle_provider.dart';
import 'package:neuroinject/main.dart';
import 'package:neuroinject/theme/favorites_manager.dart';
import 'package:neuroinject/theme/recently_viewed_manager.dart';
import 'package:neuroinject/theme/theme_manager.dart';

void main() {
  testWidgets('App boots through providers and router into the dashboard shell',
      (WidgetTester tester) async {
    // Keep the test hermetic: no network font fetches, empty prefs store.
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager()),
          ChangeNotifierProvider(create: (_) => FavoritesManager()),
          ChangeNotifierProvider(create: (_) => RecentlyViewedManager()),
          ChangeNotifierProvider(create: (_) => MuscleDataProvider()),
        ],
        child: const NeuroInjectApp(),
      ),
    );

    // The router-based app mounts a MaterialApp...
    expect(find.byType(MaterialApp), findsOneWidget);

    // ...and on the first frame the dashboard shows its loading state, since
    // muscle data is still loading asynchronously from the asset bundle.
    expect(find.text('LOADING NEUROINJECT'), findsOneWidget);
  });
}
