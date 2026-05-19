import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/entities/alert_event.dart';
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

  void init() {
    emit(AlertsLoading());
    _sub = _watchAlerts.execute().listen((active) async {
      _active = active;
      await _emitLoaded();
    }, onError: (e) => emit(AlertsError(e.toString())));
  }

  Future<void> _emitLoaded() async {
    try {
      final (thresholds, history) = await (
        _getThresholds.execute(),
        _getHistory.execute(),
      ).wait;

      emit(
        AlertsLoaded(
          activeAlerts: _active,
          thresholds: thresholds,
          history: history,
        ),
      );
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
