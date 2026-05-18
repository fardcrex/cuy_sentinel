import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

class GetLatestMetricsUseCase {
  const GetLatestMetricsUseCase(this._repository);

  final IMetricsRepository _repository;

  Future<List<Metric>> execute({required int serviceId, int limit = 50}) =>
      _repository.getLatest(serviceId: serviceId, limit: limit);
}
