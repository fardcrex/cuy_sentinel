import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/entities/alert_event.dart';
import '../../../feature/alerts/domain/entities/alert_threshold.dart';
import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit({
    required WatchActiveAlertsUseCase watchAlerts,
    required GetAlertHistoryUseCase getHistory,
    required GetAlertThresholdsUseCase getThresholds,
  }) : _watchAlerts = watchAlerts,
       _getHistory = getHistory,
       _getThresholds = getThresholds,
       super(AlertsInitial());

  final WatchActiveAlertsUseCase _watchAlerts;
  final GetAlertHistoryUseCase _getHistory;
  final GetAlertThresholdsUseCase _getThresholds;

  StreamSubscription<List<AlertEvent>>? _sub;
  List<AlertEvent> _active = [];
  List<AlertThreshold>? _thresholds;
  List<AlertEvent>? _history;

  Future<void> init() async {
    emit(AlertsLoading());
    try {
      final (thresholds, history) = await (
        _getThresholds.execute(),
        _getHistory.execute(),
      ).wait;
      _thresholds = thresholds;
      _history = history;
    } catch (e) {
      emit(AlertsError(e.toString()));
      return;
    }

    _sub = _watchAlerts.execute().listen(
      (active) {
        _active = active;
        _emitLoaded();
      },
      onError: (e) => emit(AlertsError(e.toString())),
    );
  }

  void _emitLoaded() {
    final thresholds = _thresholds;
    final history = _history;
    if (thresholds == null || history == null) return;
    emit(AlertsLoaded(
      activeAlerts: _active,
      thresholds: thresholds,
      history: history,
    ));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
