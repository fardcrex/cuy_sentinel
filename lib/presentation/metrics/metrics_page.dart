import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/metrics/application/get_metrics_history_use_case.dart';
import 'cubit/metrics_cubit.dart';
import 'cubit/metrics_state.dart';
import 'views/metrics_content_view.dart';
import 'views/metrics_error_view.dart';
import 'views/metrics_loading_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class MetricsProviderPage extends StatelessWidget {
  const MetricsProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MetricsCubit>(
      create: (ctx) => MetricsCubit(
        getHistory: ctx.read<GetMetricsHistoryUseCase>(),
      )..init(),
      child: const MetricsPage(),
    );
  }
}

class MetricsPage extends StatelessWidget {
  const MetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(
      builder: (context, state) => switch (state) {
        MetricsInitial() || MetricsLoading() => const MetricsLoadingView(),
        MetricsError(:final message) => MetricsErrorView(message: message),
        MetricsLoaded() => MetricsContentView(state: state),
      },
    );
  }
}
