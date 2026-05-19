import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/alerts/application/get_alerts_use_case.dart';
import '../../feature/metrics/application/get_latest_metrics_use_case.dart';
import '../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../feature/monitoring/application/get_services_use_case.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'views/dashboard_content_view.dart';
import 'views/dashboard_error_view.dart';
import 'views/dashboard_loading_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class DashboardProviderPage extends StatelessWidget {
  const DashboardProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (ctx) => DashboardCubit(
        watchMetrics: ctx.read<WatchLatestMetricsUseCase>(),
        watchAlerts: ctx.read<WatchActiveAlertsUseCase>(),
        getCollectorRuns: ctx.read<GetCollectorRunsUseCase>(),
        watchLastCollectorRun: ctx.read<WatchLastCollectorRunUseCase>(),
        getServices: ctx.read<GetServicesUseCase>(),
        getServiceEvents: ctx.read<GetServiceEventsUseCase>(),
      )..init(),
      child: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => switch (state) {
        DashboardInitial() ||
        DashboardLoading() => const DashboardLoadingView(),
        DashboardError(:final message) => DashboardErrorView(message: message),
        DashboardLoaded() => DashboardContentView(state: state),
      },
    );
  }
}
