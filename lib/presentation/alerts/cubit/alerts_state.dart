import '../../../feature/alerts/domain/entities/alert_event.dart';
import '../../../feature/alerts/domain/entities/alert_severity.dart';
import '../../../feature/alerts/domain/entities/alert_threshold.dart';

sealed class AlertsState {}

final class AlertsInitial extends AlertsState {}

final class AlertsLoading extends AlertsState {}

final class AlertsLoaded extends AlertsState {
  AlertsLoaded({
    required this.activeAlerts,
    required this.thresholds,
    required this.history,
  });

  final List<AlertEvent> activeAlerts;
  final List<AlertThreshold> thresholds;
  final List<AlertEvent> history;

  int get criticalCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.critical).length;

  int get warningCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.warning).length;
}

final class AlertsError extends AlertsState {
  AlertsError(this.message);
  final String message;
}
