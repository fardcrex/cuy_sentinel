import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/reconnecting_banner.dart';
import '../../../metrics/cubit/metrics_cubit.dart';
import '../../../metrics/cubit/metrics_state.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../service_model.dart';
import '../widgets/infrastructure_card.dart';
import '../widgets/service_card.dart';
import '../widgets/services_badge.dart';

class ServicesTabView extends StatelessWidget {
  const ServicesTabView({super.key, this.physics});

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final svcState = context.watch<ServicesCubit>().state;
    final mtrState = context.watch<MetricsCubit>().state;

    if (svcState is ServicesInitial ||
        svcState is ServicesLoading ||
        mtrState is MetricsInitial ||
        mtrState is MetricsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (svcState is ServicesError) {
      return Center(
        child: Text(
          svcState.message,
          style: const TextStyle(color: AppColors.danger),
        ),
      );
    }
    if (mtrState is MetricsError) {
      return Center(
        child: Text(
          mtrState.message,
          style: const TextStyle(color: AppColors.danger),
        ),
      );
    }

    final loaded = svcState as ServicesLoaded;
    final metrics = mtrState as MetricsLoaded;
    final serviceModels = loaded.services
        .map((s) => s.toModel(metrics.forService(s.id).lastOrNull))
        .toList();
    final summary = metrics.toSummaryModel();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = width >= 900;

        return SingleChildScrollView(
          physics: physics,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loaded.isReconnecting)
                ReconnectingBanner(secondsLeft: loaded.reconnectingInSeconds),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServicesBadge(label: summary.onlineLabel),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < serviceModels.length; i++) ...[
                            if (i > 0) const SizedBox(width: 20),
                            Expanded(child: ServiceCard(model: serviceModels[i])),
                          ],
                        ],
                      )
                    else
                      Column(
                        children: [
                          for (int i = 0; i < serviceModels.length; i++) ...[
                            if (i > 0) const SizedBox(height: 20),
                            ServiceCard(model: serviceModels[i]),
                          ],
                        ],
                      ),
                    const SizedBox(height: 24),
                    const InfrastructureCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
