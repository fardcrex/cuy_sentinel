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
  final Set<String> _resolvedAlertIds = {};
  final Set<String> _dismissingAlertIds = {};
  bool _isActive = false;
  bool _isReconnecting = false;
  int _secondsLeft = 0;

  Future<void> init() => activate();

  Future<void> activate() async {
    _isActive = true;
    if (_sub != null) return;

    if (_thresholds == null || _incidents == null) {
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
      if (!_isActive || isClosed) return;
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
          if (!_isActive) return;
          _active = active;
          _emitLoaded();
        }, onError: (e) => emit(AlertsError(e.toString())));
    _emitLoaded();
  }

  Future<void> deactivate() async {
    _isActive = false;
    await _sub?.cancel();
    _sub = null;
    _stopCountdown();
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
    final resolveSuccessMessage = previous is AlertsLoaded
        ? previous.resolveSuccessMessage
        : null;

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
        resolvedAlertIds: _resolvedAlertIds
            .where((id) => _active.any((alert) => alert.id == id))
            .toSet(),
        dismissingAlertIds: _dismissingAlertIds
            .where((id) => _active.any((alert) => alert.id == id))
            .toSet(),
        resolveErrorsByAlertId: Map.fromEntries(
          resolveErrorsByAlertId.entries.where(
            (entry) => _active.any((alert) => alert.id == entry.key),
          ),
        ),
        resolveSuccessMessage: resolveSuccessMessage,
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
      _resolvedAlertIds.add(alertId);
      final latest = state;
      if (latest is AlertsLoaded) {
        emit(
          latest.copyWith(
            resolvingAlertIds: {...latest.resolvingAlertIds}..remove(alertId),
            resolveSuccessMessage: 'Alerta cerrada correctamente.',
            clearResolveError: true,
          ),
        );
      }
      _emitLoaded();

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (isClosed) return;
      _dismissingAlertIds.add(alertId);
      _emitLoaded();

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (isClosed) return;
      _active = _active.where((alert) => alert.id != alertId).toList();
      _resolvedAlertIds.remove(alertId);
      _dismissingAlertIds.remove(alertId);
      _emitLoaded();
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
            clearResolveSuccess: true,
          ),
        );
      }
    }
  }

  Future<void> refreshIncidents() async {
    final current = state;
    if (current is! AlertsLoaded || current.isRefreshingIncidents) return;
    emit(current.copyWith(isRefreshingIncidents: true));
    try {
      _incidents = await _getIncidents.execute();
    } catch (_) {
      // silent — keep stale data on error
    }
    if (isClosed) return;
    final latest = state;
    if (latest is AlertsLoaded) {
      emit(
        latest.copyWith(
          incidents: _incidents,
          isRefreshingIncidents: false,
        ),
      );
    }
  }

  void clearResolveFeedback() {
    final current = state;
    if (current is! AlertsLoaded) return;
    emit(current.copyWith(clearResolveError: true, clearResolveSuccess: true));
  }

  String _resolveErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  @override
  Future<void> close() async {
    await deactivate();
    _countdownTimer?.cancel();
    return super.close();
  }
}
