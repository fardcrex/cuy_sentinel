import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

class GetMetricsHistoryUseCase {
  const GetMetricsHistoryUseCase(this._repository);

  final IMetricsRepository _repository;

  Future<List<Metric>> execute({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) => _repository.getByRange(serviceId: serviceId, from: from, to: to);
}
