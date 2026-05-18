import '../entities/alert_event.dart';
import '../entities/alert_threshold.dart';

abstract interface class IAlertsRepository {
  Future<List<AlertThreshold>> getThresholds();
  /// Real-time stream of currently active (unfired/unresolved) alerts.
  Stream<List<AlertEvent>> watchActiveAlerts();
  Future<List<AlertEvent>> getAlertHistory({int limit = 50});
  Future<void> resolveAlert(String alertId);
}
