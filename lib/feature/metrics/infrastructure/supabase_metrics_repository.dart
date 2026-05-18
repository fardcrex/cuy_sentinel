import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

// Fase 1: implementar con Supabase Realtime channel (postgres_changes INSERT)
class SupabaseMetricsRepository implements IMetricsRepository {
  @override
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  }) => Stream.error(
    UnimplementedError('SupabaseMetricsRepository.watchLatest'),
  );

  @override
  Future<List<Metric>> getByRange({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError('SupabaseMetricsRepository.getByRange');
}
