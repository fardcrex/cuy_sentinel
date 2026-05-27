import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'views/dashboard_content_view.dart';
import 'views/dashboard_error_view.dart';
import 'views/dashboard_loading_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class DashboardProviderPage extends StatelessWidget {
  const DashboardProviderPage({super.key});

  @override
  Widget build(BuildContext context) => const DashboardPage();
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => switch (state) {
        DashboardInitial() ||
        DashboardLoading() => const DashboardLoadingView(),
        DashboardError(:final message, :final source) => DashboardErrorView(message: message, source: source),
        DashboardLoaded() => DashboardContentView(state: state),
      },
    );
  }
}
