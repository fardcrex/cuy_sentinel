import '../entities/metric.dart';

abstract interface class IMetricsRepository {
  Future<List<Metric>> getLatest({required int serviceId, int limit = 50});
  Future<List<Metric>> getByRange({
    required int serviceId,
    required DateTime from,
    required DateTime to,
  });
}
