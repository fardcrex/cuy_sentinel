import 'dart:async';

import 'package:cuy_sentinel/feature/databases/application/get_database_health_use_case.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../feature/alerts/application/get_alerts_use_case.dart';
import '../../feature/metrics/application/get_latest_metrics_use_case.dart';
import '../../feature/metrics/application/get_metrics_history_use_case.dart';
import '../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../feature/monitoring/application/get_services_use_case.dart';
import '../../feature/users/application/get_users_use_case.dart';
import '../alerts/cubit/alerts_cubit.dart';
import '../auth/bloc/auth_bloc.dart';
import '../dashboard/cubit/dashboard_cubit.dart';
import '../metrics/cubit/metrics_cubit.dart';
import '../services/databases/cubit/databases_cubit.dart';
import '../services/monitored_services/cubit/services_cubit.dart';
import '../users/bloc/users_bloc.dart';
import 'app_card.dart';
import 'glass_nav_bar.dart';
import 'glass_nav_rail.dart';
import 'nav_style_cubit.dart';

/// Punto de entrada del panel autenticado.
/// Provee los cubits de dominio y delega el layout a [ResponsiveShell].
class PanelShell extends StatelessWidget {
  const PanelShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => ServicesCubit(
            getServices: ctx.read<GetServicesUseCase>(),
            watchEvents: ctx.read<WatchActiveEventsUseCase>(),
            watchRun: ctx.read<WatchLastCollectorRunUseCase>(),
          ),
        ),
        BlocProvider(
          create: (ctx) => MetricsCubit(
            getHistory: ctx.read<GetMetricsHistoryUseCase>(),
            getServices: ctx.read<GetServicesUseCase>(),
          ),
        ),
        BlocProvider(
          create: (ctx) => DatabasesCubit(
            watchHealth: ctx.read<WatchDatabaseHealthUseCase>(),
            getTableStats: ctx.read<GetTableStatsUseCase>(),
          ),
        ),
        BlocProvider(
          create: (ctx) => DashboardCubit(
            watchMetrics: ctx.read<WatchLatestMetricsUseCase>(),
            watchAlerts: ctx.read<WatchActiveAlertsUseCase>(),
            getCollectorRuns: ctx.read<GetCollectorRunsUseCase>(),
            watchLastCollectorRun: ctx.read<WatchLastCollectorRunUseCase>(),
            getServices: ctx.read<GetServicesUseCase>(),
            getServiceEvents: ctx.read<GetServiceEventsUseCase>(),
          ),
        ),
        BlocProvider(
          create: (ctx) => AlertsCubit(
            watchAlerts: ctx.read<WatchActiveAlertsUseCase>(),
            getIncidents: ctx.read<GetRecentServiceEventsUseCase>(),
            getThresholds: ctx.read<GetAlertThresholdsUseCase>(),
            resolveAlert: ctx.read<ResolveAlertUseCase>(),
          ),
        ),
        BlocProvider(
          create: (ctx) => UsersBloc(
            watchUsers: ctx.read<WatchPanelUsersUseCase>(),
            watchAccessLogs: ctx.read<WatchAccessLogsUseCase>(),
            watchPresence: ctx.read<WatchPresenceUseCase>(),
            changeUserRole: ctx.read<ChangeUserRoleUseCase>(),
          ),
        ),
        BlocProvider(create: (_) => NavStyleCubit()),
      ],
      child: _ShellRouteLifecycle(
        currentPath: currentPath,
        child: ResponsiveShell(currentPath: currentPath, child: child),
      ),
    );
  }
}

class _ShellRouteLifecycle extends StatefulWidget {
  const _ShellRouteLifecycle({required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  State<_ShellRouteLifecycle> createState() => _ShellRouteLifecycleState();
}

class _ShellRouteLifecycleState extends State<_ShellRouteLifecycle> {
  String? _activePath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRouteActivity();
  }

  @override
  void didUpdateWidget(covariant _ShellRouteLifecycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      _syncRouteActivity();
    }
  }

  void _syncRouteActivity() {
    if (_activePath == widget.currentPath) return;
    _activePath = widget.currentPath;

    final dashboard = context.read<DashboardCubit>();
    final services = context.read<ServicesCubit>();
    final metrics = context.read<MetricsCubit>();
    final databases = context.read<DatabasesCubit>();
    final alerts = context.read<AlertsCubit>();
    final users = context.read<UsersBloc>();

    if (widget.currentPath == AppRoutes.dashboard) {
      unawaited(dashboard.activate());
    } else {
      unawaited(dashboard.deactivate());
    }

    if (widget.currentPath == AppRoutes.services) {
      unawaited(services.activate());
      unawaited(databases.activate());
    } else {
      unawaited(services.deactivate());
      unawaited(databases.deactivate());
    }

    if (widget.currentPath == AppRoutes.metrics) {
      unawaited(metrics.activate());
    } else {
      unawaited(metrics.deactivate());
    }

    if (widget.currentPath == AppRoutes.alerts) {
      unawaited(alerts.activate());
    } else {
      unawaited(alerts.deactivate());
    }

    if (widget.currentPath == AppRoutes.users) {
      unawaited(users.activate());
    } else {
      unawaited(users.deactivate());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.stroke),
      ),
      title: const Text('Cerrar sesión'),
      content: const Text('¿Deseas salir del panel de monitoreo?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
  if ((confirmed ?? false) && context.mounted) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }
}

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  static const destinations = [
    _ShellDestination(
      'Dashboard',
      AppRoutes.dashboard,
      Icons.dashboard_outlined,
    ),
    _ShellDestination('Servicios', AppRoutes.services, Icons.storage_outlined),
    _ShellDestination('Métricas', AppRoutes.metrics, Icons.insights_outlined),
    _ShellDestination('Alertas', AppRoutes.alerts, Icons.notifications_none),
    _ShellDestination(
      'Usuarios',
      AppRoutes.users,
      Icons.people_outline_rounded,
    ),
  ];

  static List<NavDestinationData> get _navData => destinations
      .map((d) => NavDestinationData(label: d.label, icon: d.icon))
      .toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final selectedIndex = destinations.indexWhere(
          (d) => d.route == currentPath,
        );
        final currentIndex = selectedIndex < 0 ? 0 : selectedIndex;

        if (AppBreakpoints.isMobile(width)) {
          return _MobileShell(
            currentIndex: currentIndex,
            onNavigate: (i) => _go(context, i),
            onLogout: () => _confirmLogout(context),
            child: child,
          );
        }

        if (AppBreakpoints.isDesktop(width)) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  _DesktopSidebar(
                    currentIndex: currentIndex,
                    onTap: (i) => _go(context, i),
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppBreakpoints.contentMaxWidth,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Tablet: glass rail flotante
        return _TabletShell(
          currentIndex: currentIndex,
          onNavigate: (i) => _go(context, i),
          onLogout: () => _confirmLogout(context),
          child: child,
        );
      },
    );
  }

  void _go(BuildContext context, int index) {
    final destination = destinations[index];
    if (destination.route == currentPath) return;
    context.go(destination.route);
  }
}

// ── Mobile shell ──────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.currentIndex,
    required this.onNavigate,
    required this.onLogout,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;
  final Widget child;

  static const double _navHeight = 68;
  static const double _navBottom = 16;
  static const double _navHorizontal = 20;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final totalBottomOffset = _navHeight + _navBottom + bottomPadding;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppAssets.logoMarkShield, width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('Cuy Sentinel'),
          ],
        ),
        actions: [
          const Center(child: _AppVersionLabel(compact: true)),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.of(
                  context,
                ).padding.copyWith(bottom: totalBottomOffset),
              ),
              child: child,
            ),
          ),

          Positioned(
            left: _navHorizontal,
            right: _navHorizontal,
            bottom: _navBottom + bottomPadding,
            child: BlocBuilder<NavStyleCubit, NavGlassStyle>(
              builder: (ctx, style) => GlassNavBar(
                destinations: ResponsiveShell._navData,
                selectedIndex: currentIndex,
                onDestinationSelected: onNavigate,
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tablet shell ──────────────────────────────────────────────────────────────

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.currentIndex,
    required this.onNavigate,
    required this.onLogout,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;
  final Widget child;

  static const double _railMargin = 12;

  @override
  Widget build(BuildContext context) {
    final railTotalWidth = GlassNavRail.width + _railMargin * 2;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: railTotalWidth),
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.contentMaxWidth,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
            Positioned(
              left: _railMargin,
              top: _railMargin,
              bottom: _railMargin,
              child: BlocBuilder<NavStyleCubit, NavGlassStyle>(
                builder: (ctx, style) => GlassNavRail(
                  destinations: ResponsiveShell._navData,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onNavigate,
                  leading: Image.asset(
                    AppAssets.logoMarkShield,
                    width: 40,
                    height: 40,
                  ),
                  onLogout: onLogout,
                  style: style,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Desktop sidebar ───────────────────────────────────────────────────────────

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 304,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(right: BorderSide(color: AppColors.stroke)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(AppAssets.logoHorizontalPrimary, height: 60),
          ),
          const SizedBox(height: 24),
          Text(
            'Plataforma de monitoreo inteligente para infraestructura crítica.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          for (
            var index = 0;
            index < ResponsiveShell.destinations.length;
            index++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SidebarItem(
                destination: ResponsiveShell.destinations[index],
                selected: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
          const Spacer(),
          const AppCard(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Text('Sistema saludable'),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Todos los sistemas funcionan correctamente.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: _AppVersionLabel()),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) => SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textInactive,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => _confirmLogout(ctx),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────────

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel({this.compact = false});

  static final Future<_AppRuntimeInfo> _infoFuture = _AppRuntimeInfo.load();

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textInactive,
      fontWeight: FontWeight.w600,
    );

    return FutureBuilder<_AppRuntimeInfo>(
      future: _infoFuture,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final label = info == null
            ? (compact ? 'v...' : 'Versión ...')
            : compact
            ? 'v${info.version}'
            : 'Versión ${info.fullVersion} · ${info.platformLabel}';

        return Text(label, textAlign: TextAlign.center, style: style);
      },
    );
  }
}

class _AppRuntimeInfo {
  const _AppRuntimeInfo({
    required this.version,
    required this.buildNumber,
    required this.platformLabel,
  });

  final String version;
  final String buildNumber;
  final String platformLabel;

  String get fullVersion => '$version+$buildNumber';

  static Future<_AppRuntimeInfo> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final platformLabel = await _resolvePlatformLabel();

    return _AppRuntimeInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      platformLabel: platformLabel,
    );
  }

  static Future<String> _resolvePlatformLabel() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        await deviceInfo.webBrowserInfo;
        return 'Web';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          await deviceInfo.androidInfo;
          return 'Android';
        case TargetPlatform.iOS:
          await deviceInfo.iosInfo;
          return 'iOS';
        case TargetPlatform.macOS:
          await deviceInfo.macOsInfo;
          return 'macOS';
        case TargetPlatform.windows:
          await deviceInfo.windowsInfo;
          return 'Windows';
        case TargetPlatform.linux:
          await deviceInfo.linuxInfo;
          return 'Linux';
        case TargetPlatform.fuchsia:
          return 'Fuchsia';
      }
    } catch (_) {
      return 'Plataforma desconocida';
    }
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall;
    return Material(
      color: selected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                destination.icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                destination.label,
                style: textStyle?.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;
}
