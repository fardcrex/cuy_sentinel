import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/alerts/alerts_page.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/dashboard/dashboard_page.dart';

import '../../presentation/metrics/metrics_page.dart';
import '../../presentation/not_found/not_found_page.dart';
import '../../presentation/services/services_page.dart';
import '../../presentation/users/users_page.dart';
import '../../presentation/alert_preview/alert_preview_page.dart';
import '../../presentation/guide/guide_page.dart';
import '../../presentation/welcome/welcome_page.dart';
import '../../presentation/widgets/responsive_shell.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const welcome = '/';
  static const guide = '/guide';
  static const alertPreview = '/testalert';
  static const dashboard = '/dashboard';
  static const services = '/services';
  static const metrics = '/metrics';
  static const alerts = '/alerts';
  static const users = '/users';
}

const _publicRoutes = {
  AppRoutes.welcome,
  AppRoutes.login,
  AppRoutes.guide,
  AppRoutes.alertPreview,
};

final appNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthBloc authBloc) => GoRouter(
  navigatorKey: appNavigatorKey,
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
      pageBuilder: (context, state) => _buildPage(state, const LoginPage()),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (context, state) => _buildPage(state, const WelcomePage()),
    ),
    GoRoute(
      path: AppRoutes.guide,
      pageBuilder: (context, state) => _buildPage(state, const GuidePage()),
    ),
    GoRoute(
      path: AppRoutes.alertPreview,
      pageBuilder: (context, state) =>
          _buildPage(state, const AlertPreviewPage()),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          PanelShell(currentPath: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) =>
              _buildPage(state, const DashboardProviderPage()),
        ),
        GoRoute(
          path: AppRoutes.services,
          pageBuilder: (context, state) =>
              _buildPage(state, const ServicesProviderPage()),
        ),
        GoRoute(
          path: AppRoutes.metrics,
          pageBuilder: (context, state) =>
              _buildPage(state, const MetricsProviderPage()),
        ),
        GoRoute(
          path: AppRoutes.alerts,
          pageBuilder: (context, state) =>
              _buildPage(state, const AlertsProviderPage()),
        ),
        GoRoute(
          path: AppRoutes.users,
          pageBuilder: (context, state) => _buildPage(state, const UsersProviderPage()),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundPage(location: state.uri.toString()),
);

Page<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
  //return MaterialPage<void>(key: state.pageKey, child: child);
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
