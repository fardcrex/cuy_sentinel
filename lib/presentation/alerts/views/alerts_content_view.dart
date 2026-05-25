import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../auth/bloc/auth_bloc.dart';
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
  String? _loadedUserId;
  UserRole _currentUserRole = UserRole.viewer;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentUserRole();
  }

  Future<void> _loadCurrentUserRole() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    if (_loadedUserId == authState.user.id) return;
    _loadedUserId = authState.user.id;

    PanelUser? user;
    try {
      user = await context.read<GetPanelUserByIdUseCase>().execute(
        authState.user.id,
      );
    } catch (_) {
      user = null;
    }
    if (!mounted || _loadedUserId != authState.user.id) return;
    setState(() {
      _currentUserRole = user?.role ?? UserRole.viewer;
    });
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
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = AppBreakpoints.isDesktop(width);
        final canResolveAlerts =
            kDebugMode || _currentUserRole != UserRole.viewer;

        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            padding,
            padding,
            padding,
            padding + bottomPadding,
          ),
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
                            isResolving: widget.state.isResolving,
                            isResolved: widget.state.isResolved,
                            isDismissing: widget.state.isDismissing,
                            canResolveAlerts: canResolveAlerts,
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
                      isResolving: widget.state.isResolving,
                      isResolved: widget.state.isResolved,
                      isDismissing: widget.state.isDismissing,
                      canResolveAlerts: canResolveAlerts,
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
