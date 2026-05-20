import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/screen_header.dart';
import '../alert_model.dart';
import '../cubit/alerts_state.dart';
import '../widgets/alert_summary_badges.dart';
import '../widgets/alerts_aside.dart';
import '../widgets/alerts_section.dart';
import '../widgets/incidents_section.dart';

class AlertsContentView extends StatefulWidget {
  const AlertsContentView({super.key, required this.state});

  final AlertsLoaded state;

  @override
  State<AlertsContentView> createState() => _AlertsContentViewState();
}

class _AlertsContentViewState extends State<AlertsContentView> {
  final _scrollController = ScrollController();
  final _incidentsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIncidents() {
    final ctx = _incidentsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertModels = widget.state.activeAlerts
        .map((e) => e.toAlertModel())
        .toList();
    final incidentModels = widget.state.incidents
        .map((e) => e.toIncidentModel())
        .toList();
    final thresholdModels = widget.state.thresholds
        .map((t) => t.toModel())
        .toList();
    final summary = widget.state.toSummaryModel();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          controller: _scrollController,
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
                          AlertsSection(
                            alerts: alertModels,
                            onViewAll: _scrollToIncidents,
                          ),
                          const SizedBox(height: 24),
                          IncidentsSection(
                            key: _incidentsKey,
                            incidents: incidentModels,
                          ),
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
                    AlertsSection(
                      alerts: alertModels,
                      onViewAll: _scrollToIncidents,
                    ),
                    const SizedBox(height: 24),
                    IncidentsSection(
                      key: _incidentsKey,
                      incidents: incidentModels,
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
