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
  });

  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;
  final List<AlertEvent> activeAlerts;
  final List<CollectorRun> collectorRuns;
  final List<MonitoredService> services;
  final List<ServiceEvent> recentEvents;
}

final class DashboardError extends DashboardState {
  DashboardError(this.message);
  final String message;
}
