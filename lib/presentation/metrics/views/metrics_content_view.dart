import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/resource_chart_card.dart';
import '../../widgets/screen_header.dart';
import '../cubit/metrics_cubit.dart';
import '../cubit/metrics_state.dart';
import '../metric_model.dart';
import '../widgets/metrics_bandwidth_chart_card.dart';
import '../widgets/metrics_filter_row.dart';
import '../widgets/metrics_snmp_health_card.dart';
import '../widgets/metrics_summary_grid.dart';
import '../widgets/metrics_uptime_card.dart';

class MetricsContentView extends StatelessWidget {
  const MetricsContentView({super.key, required this.state});

  final MetricsLoaded state;

  @override
  Widget build(BuildContext context) {
    final summaryCards = state.toSummaryCards();
    final snmpRows = state.toSnmpRows();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = AppBreakpoints.isDesktop(width);

        final filterRow = MetricsFilterRow(
          selected: state.range,
          onChanged: context.read<MetricsCubit>().changeRange,
        );

        final progressBar = SizedBox(
          height: 2,
          child: state.isRefreshing
              ? const LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: Colors.transparent,
                )
              : null,
        );

        if (isWide) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: 'Métricas',
                  subtitle:
                      'Histórico de rendimiento recolectado vía SNMP cada 5 min',
                  trailing: filterRow,
                ),
                progressBar,
                const SizedBox(height: 24),
                MetricsSummaryGrid(cards: summaryCards),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          ResourceChartCard(
                            passboltMetrics: state.passboltMetrics,
                            chkmonitorMetrics: state.chkmonitorMetrics,
                          ),
                          const SizedBox(height: 20),
                          MetricsBandwidthChartCard(
                            inBuckets: state.bandwidthInBuckets,
                            outBuckets: state.bandwidthOutBuckets,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          MetricsUptimeCard(buckets: state.uptimeBuckets),
                          const SizedBox(height: 20),
                          MetricsSnmpHealthCard(rows: snmpRows),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Mobile: header scrolls away, filter row stays pinned
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                child: const ScreenHeader(
                  title: 'Métricas',
                  subtitle:
                      'Histórico de rendimiento recolectado vía SNMP cada 5 min',
                ),
              ),
            ),
            SliverToBoxAdapter(child: progressBar),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                padding: padding,
                child: filterRow,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 24, padding, padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetricsSummaryGrid(cards: summaryCards),
                    const SizedBox(height: 24),
                    ResourceChartCard(
                      passboltMetrics: state.passboltMetrics,
                      chkmonitorMetrics: state.chkmonitorMetrics,
                    ),
                    const SizedBox(height: 20),
                    MetricsBandwidthChartCard(
                      inBuckets: state.bandwidthInBuckets,
                      outBuckets: state.bandwidthOutBuckets,
                    ),
                    const SizedBox(height: 20),
                    MetricsUptimeCard(buckets: state.uptimeBuckets),
                    const SizedBox(height: 20),
                    MetricsSnmpHealthCard(rows: snmpRows),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  const _StickyFilterDelegate({required this.padding, required this.child});

  final double padding;
  final Widget child;

  static const double _verticalPadding = 12.0;
  static const double _filterHeight = 42.0;

  @override
  double get minExtent => _filterHeight + _verticalPadding * 2;

  @override
  double get maxExtent => _filterHeight + _verticalPadding * 2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: _verticalPadding,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyFilterDelegate oldDelegate) =>
      oldDelegate.padding != padding || oldDelegate.child != child;
}
