import '../../../core/utils/stream_retry.dart';
import '../domain/entities/collector_run.dart';
import '../domain/entities/db_node.dart';
import '../domain/entities/monitored_service.dart';
import '../domain/entities/service_event.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class InMemoryMonitoringRepository implements IMonitoringRepository {
  static final _passbolt = MonitoredService(
    id: 'svc-passbolt',
    serviceName: 'Passbolt',
    containerName: 'passbolt_app',
    hostIp: '192.168.1.10',
    snmpPort: 1161,
    slug: 'passbolt',
    description: 'Gestor de contraseñas auto-hospedado',
    createdAt: DateTime(2025, 3, 1),
  );

  static final _chkmonitor = MonitoredService(
    id: 'svc-chkmonitor',
    serviceName: 'ChkMonitor',
    containerName: 'chkmonitor_app',
    hostIp: '192.168.1.10',
    snmpPort: 2161,
    slug: 'chkmonitor',
    description: 'Monitor de servicios HTTP',
    createdAt: DateTime(2025, 3, 1),
  );

  static final _events = [
    ServiceEvent(
      id: 'evt-001',
      serviceId: 'svc-chkmonitor',
      serviceName: 'ChkMonitor',
      eventType: ServiceEventType.recovered,
      startedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      endedAt: DateTime.now().subtract(const Duration(days: 2, hours: 2, minutes: 47)),
      durationSeconds: 780,
      cause: 'Servicio reiniciado por actualización',
      resolved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    ServiceEvent(
      id: 'evt-002',
      serviceId: 'svc-passbolt',
      serviceName: 'Passbolt',
      eventType: ServiceEventType.degraded,
      startedAt: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
      endedAt: DateTime.now().subtract(const Duration(days: 5)),
      durationSeconds: 3600,
      cause: 'Latencia SNMP elevada (>500 ms)',
      resolved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
    ),
    ServiceEvent(
      id: 'evt-003',
      serviceId: 'svc-passbolt',
      serviceName: 'Passbolt',
      eventType: ServiceEventType.down,
      startedAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
      endedAt: DateTime.now().subtract(const Duration(days: 7)),
      durationSeconds: 7200,
      cause: 'Caída del contenedor Docker',
      resolved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
    ),
  ];

  @override
  Future<List<MonitoredService>> getServices() async =>
      [_passbolt, _chkmonitor];

  @override
  Future<MonitoredService?> getServiceById(String id) async => switch (id) {
    'svc-passbolt' => _passbolt,
    'svc-chkmonitor' => _chkmonitor,
    _ => null,
  };

  @override
  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  }) async =>
      _events.where((e) => e.serviceId == serviceId).take(limit).toList();

  @override
  Future<List<ServiceEvent>> getRecentServiceEvents({int limit = 30}) async {
    final sorted = [..._events]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sorted.take(limit).toList();
  }

  @override
  Stream<List<ServiceEvent>> watchActiveEvents({
    void Function(RetryState)? onRetry,
  }) async* {
    while (true) {
      yield _events.where((e) => e.isActive).toList();
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  Future<List<CollectorRun>> getCollectorRuns({int limit = 50}) async =>
      _buildRuns(limit);

  @override
  Stream<CollectorRun?> watchLastCollectorRun({
    void Function(RetryState)? onRetry,
  }) async* {
    var tick = 0;
    while (true) {
      final now = DateTime.now();
      final duration = 210 + (tick % 6) * 9;
      yield CollectorRun(
        id: 'run-demo-$tick',
        startedAt: now.subtract(Duration(milliseconds: duration + 50)),
        finishedAt: now,
        durationMs: duration,
        servicesPolled: 2,
        success: true,
        collectorVersion: '0.1.0',
      );
      tick++;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  Future<List<DbNode>> fetchDbNodes() async => [
    DbNode.fromJson({
      'name': 'patroni1',
      'host': 'patroni1',
      'port': 8008,
      'reachable': true,
      'role': 'primary',
      'state': 'running',
      'lag': null,
      'timeline': 2,
      'version': 150018,
    }),
    DbNode.fromJson({
      'name': 'patroni2',
      'host': 'patroni2',
      'port': 8008,
      'reachable': true,
      'role': 'replica',
      'state': 'streaming',
      'lag': 0,
      'timeline': 2,
      'version': 150018,
    }),
  ];

  static List<CollectorRun> _buildRuns(int limit) {
    final now = DateTime.now();
    return List.generate(limit.clamp(1, 50), (i) {
      final start = now.subtract(Duration(minutes: i * 5 + 1));
      final duration = 220 + (i % 7) * 12;
      return CollectorRun(
        id: 'run-seed-$i',
        startedAt: start,
        finishedAt: start.add(Duration(milliseconds: duration)),
        durationMs: duration,
        servicesPolled: 2,
        success: i != 3 && i != 11,
        errorMessage: (i == 3 || i == 11) ? 'SNMP timeout svc-passbolt' : null,
        collectorVersion: '0.1.0',
      );
    });
  }
}
