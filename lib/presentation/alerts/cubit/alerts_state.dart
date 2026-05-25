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
    this.resolvingAlertIds = const {},
    this.resolvedAlertIds = const {},
    this.dismissingAlertIds = const {},
    this.resolveErrorsByAlertId = const {},
    this.resolveErrorMessage,
    this.resolveSuccessMessage,
  });

  final List<AlertEvent> activeAlerts;
  final List<AlertThreshold> thresholds;
  final List<ServiceEvent> incidents;
  final bool isReconnecting;

  /// Segundos restantes para el próximo reintento. null cuando no reconecta.
  final int? reconnectingInSeconds;
  final Set<String> resolvingAlertIds;
  final Set<String> resolvedAlertIds;
  final Set<String> dismissingAlertIds;
  final Map<String, String> resolveErrorsByAlertId;
  final String? resolveErrorMessage;
  final String? resolveSuccessMessage;

  AlertsLoaded copyWith({
    bool? isReconnecting,
    int? reconnectingInSeconds,
    bool clearCountdown = false,
    Set<String>? resolvingAlertIds,
    Set<String>? resolvedAlertIds,
    Set<String>? dismissingAlertIds,
    Map<String, String>? resolveErrorsByAlertId,
    String? resolveErrorMessage,
    bool clearResolveError = false,
    String? resolveSuccessMessage,
    bool clearResolveSuccess = false,
  }) => AlertsLoaded(
    activeAlerts: activeAlerts,
    thresholds: thresholds,
    incidents: incidents,
    isReconnecting: isReconnecting ?? this.isReconnecting,
    reconnectingInSeconds: clearCountdown
        ? null
        : (reconnectingInSeconds ?? this.reconnectingInSeconds),
    resolvingAlertIds: resolvingAlertIds ?? this.resolvingAlertIds,
    resolvedAlertIds: resolvedAlertIds ?? this.resolvedAlertIds,
    dismissingAlertIds: dismissingAlertIds ?? this.dismissingAlertIds,
    resolveErrorsByAlertId:
        resolveErrorsByAlertId ?? this.resolveErrorsByAlertId,
    resolveErrorMessage: clearResolveError
        ? null
        : (resolveErrorMessage ?? this.resolveErrorMessage),
    resolveSuccessMessage: clearResolveSuccess
        ? null
        : (resolveSuccessMessage ?? this.resolveSuccessMessage),
  );

  bool isResolving(String alertId) => resolvingAlertIds.contains(alertId);

  bool isResolved(String alertId) => resolvedAlertIds.contains(alertId);

  bool isDismissing(String alertId) => dismissingAlertIds.contains(alertId);

  String? resolveErrorFor(String alertId) => resolveErrorsByAlertId[alertId];

  int get criticalCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.critical).length;

  int get warningCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.warning).length;
}

final class AlertsError extends AlertsState {
  AlertsError(this.message);
  final String message;
}
