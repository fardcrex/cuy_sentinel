import '../../../../core/utils/stream_retry.dart';
import '../entities/collector_run.dart';
import '../entities/db_node.dart';
import '../entities/monitored_service.dart';
import '../entities/service_event.dart';

abstract interface class IMonitoringRepository {
  Future<List<MonitoredService>> getServices();
  Future<MonitoredService?> getServiceById(String id);

  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  });
  /// All recent events across every service, ordered by started_at DESC.
  Future<List<ServiceEvent>> getRecentServiceEvents({int limit = 30});
  /// Real-time stream of currently active (unresolved) service events.
  Stream<List<ServiceEvent>> watchActiveEvents({void Function(RetryState)? onRetry});

  Future<List<CollectorRun>> getCollectorRuns({int limit = 50});

  /// Real-time stream — emits every time the collector finishes a run.
  Stream<CollectorRun?> watchLastCollectorRun({void Function(RetryState)? onRetry});

  /// Patroni cluster nodes — Phase 2 only. Returns empty list in other phases.
  Future<List<DbNode>> fetchDbNodes();
}
