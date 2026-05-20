import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../feature/databases/application/get_database_health_use_case.dart';
import '../../feature/metrics/application/get_metrics_history_use_case.dart';
import '../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../feature/monitoring/application/get_services_use_case.dart';
import '../auth/bloc/auth_bloc.dart';
import '../metrics/cubit/metrics_cubit.dart';
import '../services/databases/cubit/databases_cubit.dart';
import '../services/monitored_services/cubit/services_cubit.dart';
import 'app_card.dart';

/// Punto de entrada del panel autenticado.
/// Provee los cubits de dominio y delega el layout a [ResponsiveShell].
class PanelShell extends StatelessWidget {
  const PanelShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

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
          )..load(),
        ),
        BlocProvider(
          create: (ctx) => MetricsCubit(
            getHistory: ctx.read<GetMetricsHistoryUseCase>(),
            getServices: ctx.read<GetServicesUseCase>(),
          )..init(),
        ),
        BlocProvider(
          create: (ctx) => DatabasesCubit(
            watchHealth: ctx.read<WatchDatabaseHealthUseCase>(),
            getTableStats: ctx.read<GetTableStatsUseCase>(),
          )..load(),
        ),
      ],
      child: ResponsiveShell(currentPath: currentPath, child: child),
    );
  }
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
    // Despachar el evento limpia la sesión en el repositorio y emite
    // AuthUnauthenticated. El refreshListenable del router detecta el cambio
    // y redirige a /login automáticamente — sin context.go manual.
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final selectedIndex = destinations.indexWhere(
          (destination) => destination.route == currentPath,
        );
        final currentIndex = selectedIndex < 0 ? 0 : selectedIndex;

        if (AppBreakpoints.isMobile(width)) {
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
                IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => _confirmLogout(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              destinations: destinations
                  .map(
                    (destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                    ),
                  )
                  .toList(),
              onDestinationSelected: (index) => _go(context, index),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (AppBreakpoints.isDesktop(width))
                  _DesktopSidebar(
                    currentIndex: currentIndex,
                    onTap: (index) => _go(context, index),
                  )
                else
                  NavigationRail(
                    selectedIndex: currentIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (index) => _go(context, index),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Image.asset(
                        AppAssets.logoMarkShield,
                        width: 52,
                        height: 52,
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _AppVersionLabel(compact: true),
                          const SizedBox(height: 10),
                          IconButton(
                            tooltip: 'Cerrar sesión',
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.textInactive,
                            ),
                            onPressed: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                    ),
                    destinations: destinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
                          ),
                        )
                        .toList(),
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
      },
    );
  }

  void _go(BuildContext context, int index) {
    final destination = destinations[index];
    if (destination.route == currentPath) return;
    context.go(destination.route);
  }
}

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

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel({this.compact = false});

  static const _version = '0.1.0+1';

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = compact ? 'v0.1.0' : 'Versión $_version';

    return Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textInactive,
        fontWeight: FontWeight.w600,
      ),
    );
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
