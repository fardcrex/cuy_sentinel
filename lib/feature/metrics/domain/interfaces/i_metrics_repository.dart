import '../entities/metric.dart';

abstract interface class IMetricsRepository {
  /// Real-time stream — emits a new list every time the collector inserts
  /// a row for [serviceId]. Used by Dashboard and Services screens.
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  });

  /// One-time fetch for historical chart ranges (Métricas screen).
  Future<List<Metric>> getByRange({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  });
}
