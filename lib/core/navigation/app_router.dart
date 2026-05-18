import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/alerts_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/metrics_screen.dart';
import '../../presentation/screens/services_screen.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../../presentation/widgets/responsive_shell.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const welcome = '/';
  static const dashboard = '/dashboard';
  static const services = '/services';
  static const metrics = '/metrics';
  static const alerts = '/alerts';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          ResponsiveShell(currentPath: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.services,
          builder: (context, state) => const ServicesScreen(),
        ),
        GoRoute(
          path: AppRoutes.metrics,
          builder: (context, state) => const MetricsScreen(),
        ),
        GoRoute(
          path: AppRoutes.alerts,
          builder: (context, state) => const AlertsScreen(),
        ),
      ],
    ),
  ],
  // Fallback para rutas desconocidas
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Ruta no encontrada: ${state.uri}'))),
);
