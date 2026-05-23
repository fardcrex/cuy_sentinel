import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_toast.dart';
import '../../core/widgets/reconnecting_banner.dart';
import '../../feature/alerts/application/get_alerts_use_case.dart';
import '../../feature/monitoring/application/get_service_events_use_case.dart';
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
        getIncidents: ctx.read<GetRecentServiceEventsUseCase>(),
        getThresholds: ctx.read<GetAlertThresholdsUseCase>(),
        resolveAlert: ctx.read<ResolveAlertUseCase>(),
      )..init(),
      child: const AlertsPage(),
    );
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlertsCubit, AlertsState>(
      listenWhen: (previous, current) {
        final previousError = previous is AlertsLoaded
            ? previous.resolveErrorMessage
            : null;
        final currentError = current is AlertsLoaded
            ? current.resolveErrorMessage
            : null;
        return currentError != null && currentError != previousError;
      },
      listener: (context, state) {
        if (state case AlertsLoaded(:final resolveErrorMessage?)) {
          AppToast.error(
            context,
            'No se pudo cerrar la alerta.',
            detail: resolveErrorMessage,
          );
        }
      },
      builder: (context, state) => switch (state) {
        AlertsInitial() || AlertsLoading() => const AlertsLoadingView(),
        AlertsError(:final message) => AlertsErrorView(message: message),
        AlertsLoaded(:final isReconnecting, :final reconnectingInSeconds) =>
          Column(
            children: [
              if (isReconnecting)
                ReconnectingBanner(secondsLeft: reconnectingInSeconds),
              Expanded(child: AlertsContentView(state: state)),
            ],
          ),
      },
    );
  }
}
