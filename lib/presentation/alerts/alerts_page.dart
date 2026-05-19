import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/alerts/application/get_alerts_use_case.dart';
import 'cubit/alerts_cubit.dart';
import 'cubit/alerts_state.dart';
import 'views/alerts_content_view.dart';
import 'views/alerts_error_view.dart';
import 'views/alerts_loading_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class AlertsProviderPage extends StatelessWidget {
  const AlertsProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlertsCubit>(
      create: (ctx) => AlertsCubit(
        watchAlerts: ctx.read<WatchActiveAlertsUseCase>(),
        getHistory: ctx.read<GetAlertHistoryUseCase>(),
        getThresholds: ctx.read<GetAlertThresholdsUseCase>(),
      )..init(),
      child: const AlertsPage(),
    );
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsCubit, AlertsState>(
      builder: (context, state) => switch (state) {
        AlertsInitial() || AlertsLoading() => const AlertsLoadingView(),
        AlertsError(:final message) => AlertsErrorView(message: message),
        AlertsLoaded() => AlertsContentView(state: state),
      },
    );
  }
}
