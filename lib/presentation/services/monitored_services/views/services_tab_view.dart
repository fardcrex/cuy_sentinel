import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/reconnecting_banner.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../../feature/monitoring/domain/entities/service_status.dart';
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
      return ServicesTabLoadingSkeleton(physics: physics);
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

    // Active events override metric status: the backend emits service events
    // immediately while metrics lag by ~5 min (Go collector interval).
    final serviceModels = loaded.services
        .map((s) => s.toModel(
              metrics.forService(s.id).lastOrNull,
              activeEvents: loaded.activeEvents,
            ))
        .toList();

    final onlineCount =
        serviceModels.where((m) => m.status == ServiceStatus.online).length;
    final onlineLabel = '$onlineCount en línea';

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = width >= 900;

        return SingleChildScrollView(
          physics: physics,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loaded.isReconnecting)
                ReconnectingBanner(secondsLeft: loaded.reconnectingInSeconds),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  padding,
                  padding,
                  padding + bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServicesBadge(label: onlineLabel),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < serviceModels.length; i++) ...[
                            if (i > 0) const SizedBox(width: 20),
                            Expanded(
                              child: ServiceCard(model: serviceModels[i]),
                            ),
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

class ServicesTabLoadingSkeleton extends StatelessWidget {
  const ServicesTabLoadingSkeleton({super.key, this.physics});

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = width >= 900;

        return LoadingSkeletonPulse(
          child: SingleChildScrollView(
            physics: physics,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                padding,
                padding,
                padding,
                padding + bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(width: 136, height: 38, radius: 14),
                  const SizedBox(height: 20),
                  if (isWide)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ServiceCardSkeleton()),
                        SizedBox(width: 20),
                        Expanded(child: _ServiceCardSkeleton()),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        _ServiceCardSkeleton(),
                        SizedBox(height: 20),
                        _ServiceCardSkeleton(),
                      ],
                    ),
                  const SizedBox(height: 24),
                  const _InfrastructureSkeleton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ServiceHeroSkeleton(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(width: 150, height: 22),
                      SizedBox(height: 8),
                      SkeletonBlock(width: 120, height: 12),
                      SizedBox(height: 6),
                      SkeletonBlock(width: 100, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                SkeletonBlock(width: 86, height: 28, radius: 999),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricChipSkeleton(),
                _MetricChipSkeleton(width: 112),
                _MetricChipSkeleton(width: 94),
                _MetricChipSkeleton(width: 104),
                _MetricChipSkeleton(width: 104),
                _MetricChipSkeleton(width: 96),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: [
                _ProgressSkeleton(),
                SizedBox(height: 10),
                _ProgressSkeleton(),
                SizedBox(height: 10),
                _ProgressSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceHeroSkeleton extends StatelessWidget {
  const _ServiceHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          bottom: BorderSide(color: AppColors.stroke.withValues(alpha: 0.6)),
        ),
      ),
      child: const Center(
        child: SkeletonBlock(width: 132, height: 132, radius: 66),
      ),
    );
  }
}

class _MetricChipSkeleton extends StatelessWidget {
  const _MetricChipSkeleton({this.width = 88});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SkeletonBlock(width: width, height: 48, radius: 14);
  }
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBlock(width: 44, height: 13),
        SizedBox(width: 12),
        Expanded(child: SkeletonBlock(width: double.infinity, height: 8)),
        SizedBox(width: 12),
        SkeletonBlock(width: 42, height: 13),
      ],
    );
  }
}

class _InfrastructureSkeleton extends StatelessWidget {
  const _InfrastructureSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBlock(width: 20, height: 20, radius: 999),
              SizedBox(width: 10),
              SkeletonBlock(width: 190, height: 20),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              SkeletonBlock(width: 150, height: 32, radius: 12),
              SkeletonBlock(width: 138, height: 32, radius: 12),
              SkeletonBlock(width: 108, height: 32, radius: 12),
              SkeletonBlock(width: 154, height: 32, radius: 12),
              SkeletonBlock(width: 122, height: 32, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}
