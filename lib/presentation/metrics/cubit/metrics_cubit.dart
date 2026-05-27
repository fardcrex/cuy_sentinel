import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/metrics/application/get_metrics_history_use_case.dart';
import '../../../feature/monitoring/application/get_services_use_case.dart';
import 'metrics_range.dart';
import 'metrics_state.dart';

class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit({
    required GetMetricsHistoryUseCase getHistory,
    required GetServicesUseCase getServices,
  }) : _getHistory = getHistory,
       _getServices = getServices,
       super(const MetricsInitial());

  final GetMetricsHistoryUseCase _getHistory;
  final GetServicesUseCase _getServices;
  MetricsRange _range = MetricsRange.h1;
  String? _passboltId;
  String? _chkmonitorId;
  bool _initialized = false;

  Future<void> init() => activate();

  Future<void> activate() async {
    if (_initialized && state is MetricsLoaded) return;

    final services = await _getServices.execute();
    _passboltId = services
        .firstWhere((s) => s.slug == 'passbolt', orElse: () => services.first)
        .id;
    _chkmonitorId = services
        .firstWhere((s) => s.slug == 'chkmonitor', orElse: () => services.last)
        .id;
    _initialized = true;
    _load(_range);
  }

  Future<void> deactivate() async {}

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
        _getHistory.execute(
          serviceId: _passboltId ?? 'svc-passbolt',
          from: from,
          to: to,
        ),
        _getHistory.execute(
          serviceId: _chkmonitorId ?? 'svc-chkmonitor',
          from: from,
          to: to,
        ),
      ]);

      final passbolt = [...results[0]]
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
      final chkmonitor = [...results[1]]
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));

      emit(
        MetricsLoaded(
          passboltMetrics: passbolt,
          chkmonitorMetrics: chkmonitor,
          passboltId: _passboltId ?? '',
          chkmonitorId: _chkmonitorId ?? '',
          range: range,
          queryFrom: from,
          queryTo: to,
        ),
      );
    } catch (e) {
      emit(MetricsError(message: e.toString()));
    }
  }
}
