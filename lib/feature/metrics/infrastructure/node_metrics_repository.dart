import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

// Fase 2: implementar con Node.js API + Socket.IO
class NodeMetricsRepository implements IMetricsRepository {
  @override
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  }) => Stream.error(
    UnimplementedError('NodeMetricsRepository.watchLatest'),
  );

  @override
  Future<List<Metric>> getByRange({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError('NodeMetricsRepository.getByRange');
}
