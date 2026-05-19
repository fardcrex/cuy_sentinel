import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/metrics/application/get_metrics_history_use_case.dart';
import 'metrics_range.dart';
import 'metrics_state.dart';

class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit({required GetMetricsHistoryUseCase getHistory})
      : _getHistory = getHistory,
        super(const MetricsInitial());

  final GetMetricsHistoryUseCase _getHistory;
  MetricsRange _range = MetricsRange.h1;

  void init() => _load(_range);

  void changeRange(MetricsRange range) {
    if (_range == range) return;
    _range = range;
    _load(range);
  }

  Future<void> _load(MetricsRange range) async {
    final current = state;
    if (current is MetricsLoaded) {
      emit(current.asRefreshing());
    } else {
      emit(const MetricsLoading());
    }

    try {
      final to = DateTime.now();
      final from = to.subtract(range.duration);

      final results = await Future.wait([
        _getHistory.execute(serviceId: 'svc-passbolt', from: from, to: to),
        _getHistory.execute(serviceId: 'svc-chkmonitor', from: from, to: to),
      ]);

      final passbolt = [...results[0]]
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
      final chkmonitor = [...results[1]]
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));

      emit(MetricsLoaded(
        passboltMetrics: passbolt,
        chkmonitorMetrics: chkmonitor,
        range: range,
        queryFrom: from,
        queryTo: to,
      ));
    } catch (e) {
      emit(MetricsError(message: e.toString()));
    }
  }
}
