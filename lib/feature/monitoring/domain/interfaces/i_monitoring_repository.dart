import '../entities/collector_run.dart';
import '../entities/monitored_service.dart';
import '../entities/service_event.dart';

abstract interface class IMonitoringRepository {
  Future<List<MonitoredService>> getServices();
  Future<MonitoredService?> getServiceById(String id);

  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  });
  /// Real-time stream of currently active (unresolved) service events.
  Stream<List<ServiceEvent>> watchActiveEvents();

  Future<List<CollectorRun>> getCollectorRuns({int limit = 50});

  /// Real-time stream — emits every time the collector finishes a run.
  Stream<CollectorRun?> watchLastCollectorRun();
}
