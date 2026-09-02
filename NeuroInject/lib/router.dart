import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/muscle_provider.dart';
import 'screens/dashboard_page.dart';
import 'screens/guide/muscle_detail.dart';
import 'screens/highlight/muscle_highlighter_screen.dart';
import 'screens/highlight/captures_review_screen.dart';
import 'screens/calculator/calculator_screen.dart';
import 'screens/session/session_screen.dart';
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
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: _MuscleRoute(id: id),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/highlight/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final muscle = context.read<MuscleDataProvider>().findById(id);
        if (muscle == null) {
          return const Scaffold(body: Center(child: Text('Muscle not found')));
        }
        final view =
            int.tryParse(state.uri.queryParameters['view'] ?? '') ?? 0;
        return MuscleHighlighterScreen(muscle: muscle, viewIndex: view);
      },
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


/// Resolves `/muscle/:id` only once the corpus is loaded.
///
/// The route used to read the provider synchronously in its builder, so
/// opening the app directly on a muscle — a deep link, a shared URL, a cold
/// start on that route — raced the asynchronous load and rendered "Muscle not
/// found" for a muscle that exists.
class _MuscleRoute extends StatelessWidget {
  final String id;
  const _MuscleRoute({required this.id});

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
    return MuscleDetailScreen(muscle: muscle);
  }
}
