import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_severity.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

class InMemoryAlertsRepository implements IAlertsRepository {
  static final _thresholds = [
    const AlertThreshold(
      id: 'thr-cpu-critical',
      serviceId: null,
      metricName: 'cpu_usage_percent',
      thresholdValue: 80.0,
      severity: AlertSeverity.critical,
    ),
    const AlertThreshold(
      id: 'thr-ram-warning',
      serviceId: null,
      metricName: 'ram_usage_mb',
      thresholdValue: 500.0,
      severity: AlertSeverity.warning,
    ),
    const AlertThreshold(
      id: 'thr-disk-critical',
      serviceId: null,
      metricName: 'disk_usage_percent',
      thresholdValue: 85.0,
      severity: AlertSeverity.critical,
    ),
    const AlertThreshold(
      id: 'thr-disk-warning',
      serviceId: null,
      metricName: 'disk_usage_percent',
      thresholdValue: 40.0,
      severity: AlertSeverity.info,
    ),
    const AlertThreshold(
      id: 'thr-latency-warning',
      serviceId: null,
      metricName: 'snmp_latency_ms',
      thresholdValue: 200.0,
      severity: AlertSeverity.warning,
    ),
  ];

  static final _activeAlerts = [
    AlertEvent(
      id: 'alrt-001',
      serviceId: 'svc-passbolt',
      serviceName: 'Passbolt',
      metricName: 'Uso de memoria (RAM)',
      currentValue: 612,
      thresholdValue: 500,
      severity: AlertSeverity.warning,
      triggeredAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AlertEvent(
      id: 'alrt-002',
      serviceId: 'svc-chkmonitor',
      serviceName: 'ChkMonitor',
      metricName: 'Uso de disco',
      currentValue: 44,
      thresholdValue: 40,
      severity: AlertSeverity.info,
      triggeredAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final _history = [
    ..._activeAlerts,
    AlertEvent(
      id: 'alrt-003',
      serviceId: 'svc-passbolt',
      serviceName: 'Passbolt',
      metricName: 'CPU',
      currentValue: 83.2,
      thresholdValue: 80,
      severity: AlertSeverity.critical,
      triggeredAt: DateTime.now().subtract(const Duration(days: 3)),
      resolved: true,
      resolvedAt: DateTime.now().subtract(
        const Duration(days: 3),
      ).add(const Duration(minutes: 12)),
    ),
    AlertEvent(
      id: 'alrt-004',
      serviceId: 'svc-chkmonitor',
      serviceName: 'ChkMonitor',
      metricName: 'Latencia SNMP',
      currentValue: 340,
      thresholdValue: 200,
      severity: AlertSeverity.warning,
      triggeredAt: DateTime.now().subtract(const Duration(days: 5)),
      resolved: true,
      resolvedAt: DateTime.now().subtract(const Duration(days: 5)).add(
        const Duration(hours: 1),
      ),
    ),
  ];

  @override
  Stream<List<AlertEvent>> watchActiveAlerts() async* {
    while (true) {
      yield List.of(_activeAlerts);
      await Future.delayed(const Duration(seconds: 8));
    }
  }

  @override
  Future<List<AlertThreshold>> getThresholds() async => List.of(_thresholds);

  @override
  Future<List<AlertEvent>> getAlertHistory({int limit = 50}) async =>
      _history.take(limit).toList();

  @override
  Future<void> resolveAlert(String alertId) async {
    _activeAlerts.removeWhere((a) => a.id == alertId);
  }
}
