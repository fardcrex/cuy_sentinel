import '../../../feature/alerts/domain/entities/alert_event.dart';
import '../../../feature/alerts/domain/entities/alert_severity.dart';
import '../../../feature/alerts/domain/entities/alert_threshold.dart';
import '../../../feature/monitoring/domain/entities/service_event.dart';

sealed class AlertsState {}

final class AlertsInitial extends AlertsState {}

final class AlertsLoading extends AlertsState {}

final class AlertsLoaded extends AlertsState {
  AlertsLoaded({
    required this.activeAlerts,
    required this.thresholds,
    required this.incidents,
    this.isReconnecting = false,
    this.reconnectingInSeconds,
  });

  final List<AlertEvent> activeAlerts;
  final List<AlertThreshold> thresholds;
  final List<ServiceEvent> incidents;
  final bool isReconnecting;
  /// Segundos restantes para el próximo reintento. null cuando no reconecta.
  final int? reconnectingInSeconds;

  AlertsLoaded copyWith({
    bool? isReconnecting,
    int? reconnectingInSeconds,
    bool clearCountdown = false,
  }) => AlertsLoaded(
        activeAlerts: activeAlerts,
        thresholds: thresholds,
        incidents: incidents,
        isReconnecting: isReconnecting ?? this.isReconnecting,
        reconnectingInSeconds: clearCountdown
            ? null
            : (reconnectingInSeconds ?? this.reconnectingInSeconds),
      );

  int get criticalCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.critical).length;

  int get warningCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.warning).length;
}

final class AlertsError extends AlertsState {
  AlertsError(this.message);
  final String message;
}
