import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_toast.dart';
import '../../core/widgets/reconnecting_banner.dart';
import 'cubit/alerts_cubit.dart';
import 'cubit/alerts_state.dart';
import 'views/alerts_content_view.dart';
import 'views/alerts_error_view.dart';
import 'views/alerts_loading_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class AlertsProviderPage extends StatelessWidget {
  const AlertsProviderPage({super.key});

  @override
  Widget build(BuildContext context) => const AlertsPage();
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
        final previousSuccess = previous is AlertsLoaded
            ? previous.resolveSuccessMessage
            : null;
        final currentSuccess = current is AlertsLoaded
            ? current.resolveSuccessMessage
            : null;
        return (currentError != null && currentError != previousError) ||
            (currentSuccess != null && currentSuccess != previousSuccess);
      },
      listener: (context, state) {
        if (state case AlertsLoaded(:final resolveErrorMessage?)) {
          AppToast.error(
            context,
            'No se pudo cerrar la alerta.',
            detail: resolveErrorMessage,
          );
          context.read<AlertsCubit>().clearResolveFeedback();
        }
        if (state case AlertsLoaded(:final resolveSuccessMessage?)) {
          AppToast.success(context, resolveSuccessMessage);
          context.read<AlertsCubit>().clearResolveFeedback();
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
