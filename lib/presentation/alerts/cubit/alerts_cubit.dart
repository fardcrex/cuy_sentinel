import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/stream_retry.dart';
import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/entities/alert_event.dart';
import '../../../feature/alerts/domain/entities/alert_threshold.dart';
import '../../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../../feature/monitoring/domain/entities/service_event.dart';
import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit({
    required WatchActiveAlertsUseCase watchAlerts,
    required GetRecentServiceEventsUseCase getIncidents,
    required GetAlertThresholdsUseCase getThresholds,
    required ResolveAlertUseCase resolveAlert,
  }) : _watchAlerts = watchAlerts,
       _getIncidents = getIncidents,
       _getThresholds = getThresholds,
       _resolveAlert = resolveAlert,
       super(AlertsInitial());

  final WatchActiveAlertsUseCase _watchAlerts;
  final GetRecentServiceEventsUseCase _getIncidents;
  final GetAlertThresholdsUseCase _getThresholds;
  final ResolveAlertUseCase _resolveAlert;

  StreamSubscription<List<AlertEvent>>? _sub;
  Timer? _countdownTimer;
  List<AlertEvent> _active = [];
  List<AlertThreshold>? _thresholds;
  List<ServiceEvent>? _incidents;
  bool _isReconnecting = false;
  int _secondsLeft = 0;

  Future<void> init() async {
    emit(AlertsLoading());
    try {
      final (thresholds, incidents) = await (
        _getThresholds.execute(),
        _getIncidents.execute(),
      ).wait;
      _thresholds = thresholds;
      _incidents = incidents;
    } catch (e) {
      emit(AlertsError(e.toString()));
      return;
    }

    _sub = _watchAlerts
        .execute(
          onRetry: (retryState) {
            switch (retryState) {
              case Retrying(:final backoff):
                _startCountdown(backoff);
              case Reconnected():
                _stopCountdown();
            }
          },
        )
        .listen((active) {
          _active = active;
          _emitLoaded();
        }, onError: (e) => emit(AlertsError(e.toString())));
  }

  void _startCountdown(Duration backoff) {
    _isReconnecting = true;
    _secondsLeft = backoff.inSeconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) _secondsLeft--;
      _emitLoaded();
    });
    _emitLoaded();
  }

  void _stopCountdown() {
    _isReconnecting = false;
    _secondsLeft = 0;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _emitLoaded();
  }

  void _emitLoaded() {
    final thresholds = _thresholds;
    final incidents = _incidents;
    if (thresholds == null || incidents == null) return;
    final previous = state;
    final resolvingAlertIds = previous is AlertsLoaded
        ? previous.resolvingAlertIds
        : const <String>{};
    final resolveErrorsByAlertId = previous is AlertsLoaded
        ? previous.resolveErrorsByAlertId
        : const <String, String>{};

    emit(
      AlertsLoaded(
        activeAlerts: _active,
        thresholds: thresholds,
        incidents: incidents,
        isReconnecting: _isReconnecting,
        reconnectingInSeconds: _isReconnecting ? _secondsLeft : null,
        resolvingAlertIds: resolvingAlertIds
            .where((id) => _active.any((alert) => alert.id == id))
            .toSet(),
        resolveErrorsByAlertId: Map.fromEntries(
          resolveErrorsByAlertId.entries.where(
            (entry) => _active.any((alert) => alert.id == entry.key),
          ),
        ),
      ),
    );
  }

  Future<void> resolveAlert(String alertId) async {
    final current = state;
    if (current is! AlertsLoaded || current.isResolving(alertId)) return;

    emit(
      current.copyWith(
        resolvingAlertIds: {...current.resolvingAlertIds, alertId},
        resolveErrorsByAlertId: Map.of(current.resolveErrorsByAlertId)
          ..remove(alertId),
        clearResolveError: true,
      ),
    );

    try {
      await _resolveAlert.execute(alertId);
      final latest = state;
      if (latest is AlertsLoaded) {
        emit(
          latest.copyWith(
            resolvingAlertIds: {...latest.resolvingAlertIds}..remove(alertId),
            resolveErrorsByAlertId: Map.of(latest.resolveErrorsByAlertId)
              ..remove(alertId),
            clearResolveError: true,
          ),
        );
      }
    } catch (e) {
      final latest = state;
      if (latest is AlertsLoaded) {
        final message = _resolveErrorMessage(e);
        emit(
          latest.copyWith(
            resolvingAlertIds: {...latest.resolvingAlertIds}..remove(alertId),
            resolveErrorsByAlertId: {
              ...latest.resolveErrorsByAlertId,
              alertId: message,
            },
            resolveErrorMessage: message,
          ),
        );
      }
    }
  }

  String _resolveErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
