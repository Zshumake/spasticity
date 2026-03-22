import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/muscle_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'theme/favorites_manager.dart';
import 'theme/recently_viewed_manager.dart';

void main() {
  runApp(
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
}

class NeuroInjectApp extends StatelessWidget {
  const NeuroInjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    return MaterialApp.router(
      title: 'NeuroInject — Spasticity Injection Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      routerConfig: router,
    );
  }
}
