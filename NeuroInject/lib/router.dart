import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/muscle_provider.dart';
import 'models/muscle.dart';
import 'screens/dashboard_page.dart';
import 'screens/guide/muscle_detail.dart';
import 'screens/highlight/muscle_highlighter_screen.dart';
import 'screens/highlight/captures_review_screen.dart';
import 'screens/calculator/calculator_screen.dart';
import 'screens/session/session_screen.dart';
import 'screens/session/live_session_screen.dart';
import 'screens/identify/identify_screen.dart';
import 'screens/plan/pattern_plan_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/group/:name',
      builder: (context, state) {
        final name = state.pathParameters['name'] ?? 'All';
        return DashboardPage(initialCategory: name);
      },
    ),
    GoRoute(
      path: '/muscle/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        // The platform page, not a custom fade+slide: the custom transition
        // dropped the iOS edge-swipe back gesture on the most-visited screen
        // in the app. CupertinoPage keeps it (and is the Material default on
        // iOS anyway, so the other routes already behave this way).
        return CupertinoPage<void>(
          key: state.pageKey,
          child: _MuscleRoute(
            id: id,
            builder: (muscle) => MuscleDetailScreen(muscle: muscle),
          ),
        );
      },
    ),
    GoRoute(
      path: '/highlight/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final view =
            int.tryParse(state.uri.queryParameters['view'] ?? '') ?? 0;
        return _MuscleRoute(
          id: id,
          builder: (muscle) =>
              MuscleHighlighterScreen(muscle: muscle, viewIndex: view),
        );
      },
    ),
    GoRoute(
      path: '/session/live',
      builder: (context, state) => const LiveSessionScreen(),
    ),
    GoRoute(
      path: '/pattern/:id/plan',
      builder: (context, state) =>
          PatternPlanScreen(patternId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/identify',
      builder: (context, state) => const IdentifyScreen(),
    ),
    GoRoute(
      path: '/captures',
      builder: (context, state) => const CapturesReviewScreen(),
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) {
        // Optional deep-link seed, e.g. /calculator?brand=Botox&dose=150
        final brand = state.uri.queryParameters['brand'];
        final dose = double.tryParse(state.uri.queryParameters['dose'] ?? '');
        return CalculatorScreen(initialBrand: brand, initialDose: dose);
      },
    ),
    GoRoute(
      path: '/session',
      builder: (context, state) => const SessionScreen(),
    ),
  ],
);


/// Resolves a `/…/:id` muscle route only once the corpus is loaded.
///
/// These routes used to read the provider synchronously in their builders, so
/// opening the app directly on one — a deep link, a shared URL, a cold start —
/// raced the asynchronous load and rendered "Muscle not found" for a muscle
/// that exists. Every muscle-keyed route goes through here so the fix cannot
/// be applied to one and forgotten on the next.
class _MuscleRoute extends StatelessWidget {
  final String id;
  final Widget Function(Muscle muscle) builder;
  const _MuscleRoute({required this.id, required this.builder});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MuscleDataProvider>();
    if (!data.isLoaded) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final muscle = data.findById(id);
    if (muscle == null) {
      return const Scaffold(body: Center(child: Text('Muscle not found')));
    }
    return builder(muscle);
  }
}
