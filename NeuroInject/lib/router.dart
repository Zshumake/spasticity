import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/muscle_provider.dart';
import 'screens/dashboard_page.dart';
import 'screens/guide/muscle_detail.dart';
import 'screens/highlight/muscle_highlighter_screen.dart';
import 'screens/calculator/calculator_screen.dart';
import 'screens/session/session_screen.dart';

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
        final provider = context.read<MuscleDataProvider>();
        final muscle = provider.findById(id);
        if (muscle == null) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const Scaffold(body: Center(child: Text('Muscle not found'))),
            transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
          );
        }
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: MuscleDetailScreen(muscle: muscle),
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
        return MuscleHighlighterScreen(muscle: muscle);
      },
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
