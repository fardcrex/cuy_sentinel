import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/screen_header.dart';
import '../alert_model.dart';
import '../cubit/alerts_state.dart';
import '../widgets/alert_summary_badges.dart';
import '../widgets/alerts_aside.dart';
import '../widgets/alerts_section.dart';
import '../widgets/incidents_section.dart';

class AlertsContentView extends StatelessWidget {
  const AlertsContentView({super.key, required this.state});

  final AlertsLoaded state;

  @override
  Widget build(BuildContext context) {
    final alertModels = state.activeAlerts
        .map((event) => event.toAlertModel())
        .toList();
    final incidentModels = state.history
        .map((event) => event.toIncidentModel())
        .toList();
    final thresholdModels = state.thresholds
        .map((threshold) => threshold.toModel())
        .toList();
    final summary = state.toSummaryModel();

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
                title: 'Alertas',
                subtitle:
                    'Umbrales derivados de métricas SNMP + historial de incidentes',
                trailing: AlertSummaryBadges(summary: summary),
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          AlertsSection(alerts: alertModels),
                          const SizedBox(height: 24),
                          IncidentsSection(incidents: incidentModels),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: AlertsAside(thresholds: thresholdModels),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    AlertsAside(thresholds: thresholdModels),
                    const SizedBox(height: 24),
                    AlertsSection(alerts: alertModels),
                    const SizedBox(height: 24),
                    IncidentsSection(incidents: incidentModels),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
