import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

// Phase 1: implementar con Supabase
class SupabaseMetricsRepository implements IMetricsRepository {
  @override
  Future<List<Metric>> getLatest({
    required int serviceId,
    int limit = 50,
  }) => throw UnimplementedError('SupabaseMetricsRepository.getLatest');

  @override
  Future<List<Metric>> getByRange({
    required int serviceId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError('SupabaseMetricsRepository.getByRange');
}
