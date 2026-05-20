import '../../../core/utils/stream_retry.dart';
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
      thresholdValue: 70.0,
      severity: AlertSeverity.warning,
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
      currentValue: 73,
      thresholdValue: 70,
      severity: AlertSeverity.warning,
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
      resolvedAt: DateTime.now()
          .subtract(const Duration(days: 3))
          .add(const Duration(minutes: 12)),
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
      resolvedAt: DateTime.now()
          .subtract(const Duration(days: 5))
          .add(const Duration(hours: 1)),
    ),
  ];

  static bool _nuclearDemoFired = false;
  // instancia (no static) para que se resetee con hot restart y en cada
  // nuevo InMemoryAlertsRepository que se cree
  bool _demoDisconnectFired = false;

  // Alertas que "llegaron" mientras el stream estaba offline en el demo.
  // Se agregan durante la ventana de desconexión simulada para que el
  // catchup de AlertNotifierCubit las encuentre al reconectar.
  static final _demomissedAlerts = [
    AlertEvent(
      id: 'alrt-missed-001',
      serviceId: 'svc-passbolt',
      serviceName: 'Passbolt',
      metricName: 'Uso de CPU',
      currentValue: 91.5,
      thresholdValue: 80,
      severity: AlertSeverity.critical,
      triggeredAt: DateTime(2099), // se sobreescribe al insertar
    ),
    AlertEvent(
      id: 'alrt-missed-002',
      serviceId: 'svc-chkmonitor',
      serviceName: 'ChkMonitor',
      metricName: 'Latencia SNMP',
      currentValue: 312,
      thresholdValue: 200,
      severity: AlertSeverity.warning,
      triggeredAt: DateTime(2099),
    ),
  ];

  @override
  Stream<List<AlertEvent>> watchActiveAlerts({
    void Function(RetryState)? onRetry,
  }) async* {
    yield List.of(_activeAlerts);

    if (!_demoDisconnectFired) {
      _demoDisconnectFired = true;

      // T+25s: simular desconexión con backoff de 8s
      await Future.delayed(const Duration(seconds: 25));
      const demoBackoff = Duration(seconds: 8);
      onRetry?.call(Retrying(demoBackoff));

      // T+14s: agregar alertas "perdidas" al historial durante el offline
      await Future.delayed(const Duration(seconds: 4));
      _insertMissedAlertsToHistory();

      // T+18s: reconexión — banner desaparece
      await Future.delayed(const Duration(seconds: 4));
      onRetry?.call(Reconnected());
      yield List.of(_activeAlerts);
    }

    while (true) {
      await Future.delayed(const Duration(seconds: 8));
      yield List.of(_activeAlerts);
    }
  }

  void _insertMissedAlertsToHistory() {
    final now = DateTime.now();
    for (var i = 0; i < _demomissedAlerts.length; i++) {
      final alert = AlertEvent(
        id: _demomissedAlerts[i].id,
        serviceId: _demomissedAlerts[i].serviceId,
        serviceName: _demomissedAlerts[i].serviceName,
        metricName: _demomissedAlerts[i].metricName,
        currentValue: _demomissedAlerts[i].currentValue,
        thresholdValue: _demomissedAlerts[i].thresholdValue,
        severity: _demomissedAlerts[i].severity,
        triggeredAt: now.add(Duration(seconds: i * 2)),
      );
      if (!_history.any((a) => a.id == alert.id)) {
        _history.insert(0, alert);
      }
    }
  }

  @override
  Future<List<AlertEvent>> getAlertsSince(DateTime since) async => _history
      .where((a) => a.triggeredAt.isAfter(since) && !a.resolved)
      .toList();

  @override
  Stream<AlertEvent> watchAlertInserts({void Function()? onSubscribed}) async* {
    // Primera suscripción: onSubscribed dispara catchup (vacío al inicio).
    onSubscribed?.call();

    // T+33s: simular reconexión — onSubscribed dispara catchup que
    // encuentra las alertas insertadas durante el offline.
    await Future.delayed(const Duration(seconds: 33));
    onSubscribed?.call();

    // T+42s: nuclear demo como antes.
    await Future.delayed(const Duration(seconds: 24));
    if (!_nuclearDemoFired) {
      _nuclearDemoFired = true;
      final nuclear = AlertEvent(
        id: 'alrt-nuclear-demo',
        serviceId: 'svc-passbolt',
        serviceName: 'Passbolt',
        metricName: 'Intrusión de Sistema',
        currentValue: 9999,
        thresholdValue: 0,
        severity: AlertSeverity.nuclear,
        triggeredAt: DateTime.now(),
      );
      _activeAlerts.insert(0, nuclear);
      yield nuclear;
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
