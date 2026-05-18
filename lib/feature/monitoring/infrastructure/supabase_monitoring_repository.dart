import '../domain/entities/monitored_service.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

// Phase 1: implementar con Supabase
class SupabaseMonitoringRepository implements IMonitoringRepository {
  @override
  Future<List<MonitoredService>> getServices() =>
      throw UnimplementedError('SupabaseMonitoringRepository.getServices');
}
