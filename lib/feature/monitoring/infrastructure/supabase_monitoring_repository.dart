import '../domain/entities/collector_run.dart';
import '../domain/entities/monitored_service.dart';
import '../domain/entities/service_event.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

// Fase 1: implementar con Supabase client
class SupabaseMonitoringRepository implements IMonitoringRepository {
  @override
  Future<List<MonitoredService>> getServices() =>
      throw UnimplementedError('SupabaseMonitoringRepository.getServices');

  @override
  Future<MonitoredService?> getServiceById(String id) =>
      throw UnimplementedError('SupabaseMonitoringRepository.getServiceById');

  @override
  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  }) => throw UnimplementedError(
    'SupabaseMonitoringRepository.getServiceEvents',
  );

  @override
  Stream<List<ServiceEvent>> watchActiveEvents() => Stream.error(
    UnimplementedError('SupabaseMonitoringRepository.watchActiveEvents'),
  );

  @override
  Future<List<CollectorRun>> getCollectorRuns({int limit = 50}) =>
      throw UnimplementedError('SupabaseMonitoringRepository.getCollectorRuns');

  @override
  Stream<CollectorRun?> watchLastCollectorRun() => Stream.error(
    UnimplementedError('SupabaseMonitoringRepository.watchLastCollectorRun'),
  );
}
