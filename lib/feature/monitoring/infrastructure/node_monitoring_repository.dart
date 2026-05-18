import '../domain/entities/collector_run.dart';
import '../domain/entities/monitored_service.dart';
import '../domain/entities/service_event.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

// Fase 2: implementar con Node.js API + Socket.IO
class NodeMonitoringRepository implements IMonitoringRepository {
  @override
  Future<List<MonitoredService>> getServices() =>
      throw UnimplementedError('NodeMonitoringRepository.getServices');

  @override
  Future<MonitoredService?> getServiceById(String id) =>
      throw UnimplementedError('NodeMonitoringRepository.getServiceById');

  @override
  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  }) => throw UnimplementedError('NodeMonitoringRepository.getServiceEvents');

  @override
  Stream<List<ServiceEvent>> watchActiveEvents() => Stream.error(
    UnimplementedError('NodeMonitoringRepository.watchActiveEvents'),
  );

  @override
  Future<List<CollectorRun>> getCollectorRuns({int limit = 50}) =>
      throw UnimplementedError('NodeMonitoringRepository.getCollectorRuns');

  @override
  Stream<CollectorRun?> watchLastCollectorRun() => Stream.error(
    UnimplementedError('NodeMonitoringRepository.watchLastCollectorRun'),
  );
}
