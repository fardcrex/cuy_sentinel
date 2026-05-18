import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/screens/alerts_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/metrics_screen.dart';
import '../../presentation/screens/not_found_screen.dart';
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

const _publicRoutes = {AppRoutes.welcome, AppRoutes.login};

GoRouter createAppRouter(AuthBloc authBloc) => GoRouter(
      initialLocation: AppRoutes.welcome,
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final isAuthenticated = authBloc.state is AuthAuthenticated;
        final loc = state.matchedLocation;

        if (!isAuthenticated && !_publicRoutes.contains(loc)) {
          return AppRoutes.login;
        }
        if (isAuthenticated && loc == AppRoutes.login) {
          return AppRoutes.dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) =>
              _buildPage(state, const LoginScreen()),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          pageBuilder: (context, state) =>
              _buildPage(state, const WelcomeScreen()),
        ),
        ShellRoute(
          builder: (context, state, child) => ResponsiveShell(
            currentPath: state.matchedLocation,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              pageBuilder: (context, state) =>
                  _buildPage(state, const DashboardScreen()),
            ),
            GoRoute(
              path: AppRoutes.services,
              pageBuilder: (context, state) =>
                  _buildPage(state, const ServicesScreen()),
            ),
            GoRoute(
              path: AppRoutes.metrics,
              pageBuilder: (context, state) =>
                  _buildPage(state, const MetricsScreen()),
            ),
            GoRoute(
              path: AppRoutes.alerts,
              pageBuilder: (context, state) =>
                  _buildPage(state, const AlertsScreen()),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) =>
          NotFoundScreen(location: state.uri.toString()),
    );

Page<void> _buildPage(GoRouterState state, Widget child) {
  if (kIsWeb) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
  return MaterialPage<void>(key: state.pageKey, child: child);
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
