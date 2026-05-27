import '../../../feature/metrics/domain/entities/metric.dart';
import 'metrics_range.dart';

sealed class MetricsState {
  const MetricsState();
}

final class MetricsInitial extends MetricsState {
  const MetricsInitial();
}

final class MetricsLoading extends MetricsState {
  const MetricsLoading();
}

final class MetricsLoaded extends MetricsState {
  const MetricsLoaded({
    required this.passboltMetrics,
    required this.chkmonitorMetrics,
    required this.passboltId,
    required this.chkmonitorId,
    required this.range,
    required this.queryFrom,
    required this.queryTo,
    this.isRefreshing = false,
  });

  /// Ascendente: índice 0 = más antiguo, last = más reciente.
  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;
  final String passboltId;
  final String chkmonitorId;
  final MetricsRange range;
  final DateTime queryFrom;
  final DateTime queryTo;
  final bool isRefreshing;

  MetricsLoaded asRefreshing() => MetricsLoaded(
        passboltMetrics: passboltMetrics,
        chkmonitorMetrics: chkmonitorMetrics,
        passboltId: passboltId,
        chkmonitorId: chkmonitorId,
        range: range,
        queryFrom: queryFrom,
        queryTo: queryTo,
        isRefreshing: true,
      );

  List<Metric> forService(String serviceId) {
    if (serviceId == passboltId) return passboltMetrics;
    if (serviceId == chkmonitorId) return chkmonitorMetrics;
    return const [];
  }
}

final class MetricsError extends MetricsState {
  const MetricsError({required this.message});
  final String message;
}
