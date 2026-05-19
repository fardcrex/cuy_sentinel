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

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Métricas',
                subtitle:
                    'Histórico de rendimiento recolectado vía SNMP cada 5 min',
                trailing: MetricsFilterRow(
                  selected: state.range,
                  onChanged: context.read<MetricsCubit>().changeRange,
                ),
              ),
              SizedBox(
                height: 2,
                child: state.isRefreshing
                    ? const LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: Colors.transparent,
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              MetricsSummaryGrid(cards: summaryCards),
              const SizedBox(height: 24),
              if (isWide)
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
                )
              else
                Column(
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
                    const SizedBox(height: 20),
                    MetricsUptimeCard(buckets: state.uptimeBuckets),
                    const SizedBox(height: 20),
                    MetricsSnmpHealthCard(rows: snmpRows),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
