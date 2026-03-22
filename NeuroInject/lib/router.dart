import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/muscle_provider.dart';
import 'screens/dashboard_page.dart';
import 'screens/guide/muscle_detail.dart';
import 'screens/calculator/calculator_screen.dart';

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
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final provider = context.read<MuscleDataProvider>();
        final muscle = provider.findById(id);
        if (muscle == null) {
          return const Scaffold(
            body: Center(child: Text('Muscle not found')),
          );
        }
        return MuscleDetailScreen(muscle: muscle);
      },
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) => const CalculatorScreen(),
    ),
  ],
);
