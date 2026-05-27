import '../../../feature/alerts/domain/entities/alert_event.dart';
import '../../../feature/metrics/domain/entities/metric.dart';
import '../../../feature/monitoring/domain/entities/collector_run.dart';
import '../../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../../feature/monitoring/domain/entities/service_event.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  DashboardLoaded({
    required this.passboltMetrics,
    required this.chkmonitorMetrics,
    required this.activeAlerts,
    required this.collectorRuns,
    required this.services,
    required this.recentEvents,
    required this.activeServiceEvents,
    this.isRefreshing = false,
  });

  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;
  final List<AlertEvent> activeAlerts;
  final List<CollectorRun> collectorRuns;
  final List<MonitoredService> services;
  /// Historical events shown in RecentEventsCard (updated in real-time).
  final List<ServiceEvent> recentEvents;
  /// Currently active (unresolved) service events — used to override stale metric status.
  final List<ServiceEvent> activeServiceEvents;
  final bool isRefreshing;

  DashboardLoaded asRefreshing() => DashboardLoaded(
    passboltMetrics: passboltMetrics,
    chkmonitorMetrics: chkmonitorMetrics,
    activeAlerts: activeAlerts,
    collectorRuns: collectorRuns,
    services: services,
    recentEvents: recentEvents,
    activeServiceEvents: activeServiceEvents,
    isRefreshing: true,
  );
}

final class DashboardError extends DashboardState {
  DashboardError(this.message, {required this.source});
  final String message;
  final String source;
}
