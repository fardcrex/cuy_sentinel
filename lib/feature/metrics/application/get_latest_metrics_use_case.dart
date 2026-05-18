import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

class WatchLatestMetricsUseCase {
  const WatchLatestMetricsUseCase(this._repository);

  final IMetricsRepository _repository;

  Stream<List<Metric>> execute({required String serviceId, int limit = 50}) =>
      _repository.watchLatest(serviceId: serviceId, limit: limit);
}
