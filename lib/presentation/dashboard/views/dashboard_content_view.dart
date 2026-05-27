import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/bandwidth_chart_card.dart';
import '../../widgets/collector_health_card.dart';
import '../../widgets/recent_events_card.dart';
import '../../widgets/resource_chart_card.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/services_status_card.dart';
import '../cubit/dashboard_state.dart';
import '../dashboard_model.dart';
import '../widgets/dashboard_header_actions.dart';
import '../widgets/dashboard_stats_grid.dart';

class DashboardContentView extends StatelessWidget {
  const DashboardContentView({super.key, required this.state});

  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    final statCards = state.toStatCards();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = width >= 1100;
        final isMobile = AppBreakpoints.isMobile(width);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            padding,
            padding,
            padding,
            padding + bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                const DashboardHeaderActions()
              else
                const ScreenHeader(
                  title: 'Dashboard',
                  subtitle: 'Resumen general de la infraestructura monitoreada',
                  trailing: DashboardHeaderActions(),
                ),
              SizedBox(height: isMobile ? 12 : 24),
              DashboardStatsGrid(cards: statCards),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          ResourceChartCard(
                            passboltMetrics: state.passboltMetrics,
                            chkmonitorMetrics: state.chkmonitorMetrics,
                          ),
                          const SizedBox(height: 20),
                          BandwidthChartCard(
                            inBuckets: state.bandwidthInBuckets,
                            outBuckets: state.bandwidthOutBuckets,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          ServicesStatusCard(
                            services: state.services,
                            passboltMetrics: state.passboltMetrics,
                            chkmonitorMetrics: state.chkmonitorMetrics,
                            activeServiceEvents: state.activeServiceEvents,
                          ),
                          const SizedBox(height: 20),
                          CollectorHealthCard(runs: state.collectorRuns),
                          const SizedBox(height: 20),
                          RecentEventsCard(
                            events: state.recentEvents,
                            services: state.services,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    ServicesStatusCard(
                      services: state.services,
                      passboltMetrics: state.passboltMetrics,
                      chkmonitorMetrics: state.chkmonitorMetrics,
                    ),
                    const SizedBox(height: 20),
                    ResourceChartCard(
                      passboltMetrics: state.passboltMetrics,
                      chkmonitorMetrics: state.chkmonitorMetrics,
                    ),
                    const SizedBox(height: 20),
                    BandwidthChartCard(
                      inBuckets: state.bandwidthInBuckets,
                      outBuckets: state.bandwidthOutBuckets,
                    ),
                    const SizedBox(height: 20),
                    CollectorHealthCard(runs: state.collectorRuns),
                    const SizedBox(height: 20),
                    RecentEventsCard(
                      events: state.recentEvents,
                      services: state.services,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
