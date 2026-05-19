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
    required this.range,
    required this.queryFrom,
    required this.queryTo,
    this.isRefreshing = false,
  });

  /// Ascendente: índice 0 = más antiguo, last = más reciente.
  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;
  final MetricsRange range;
  final DateTime queryFrom;
  final DateTime queryTo;
  final bool isRefreshing;

  MetricsLoaded asRefreshing() => MetricsLoaded(
        passboltMetrics: passboltMetrics,
        chkmonitorMetrics: chkmonitorMetrics,
        range: range,
        queryFrom: queryFrom,
        queryTo: queryTo,
        isRefreshing: true,
      );

  /// Preservado — usado por services_tab_view.dart.
  List<Metric> forService(String serviceId) => switch (serviceId) {
        'svc-passbolt' => passboltMetrics,
        'svc-chkmonitor' => chkmonitorMetrics,
        _ => const [],
      };
}

final class MetricsError extends MetricsState {
  const MetricsError({required this.message});
  final String message;
}
