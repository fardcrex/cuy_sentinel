import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/stream_retry.dart';
import '../../../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../../../feature/monitoring/application/get_services_use_case.dart';
import '../../../../feature/monitoring/domain/entities/collector_run.dart';
import '../../../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../../../feature/monitoring/domain/entities/service_event.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit({
    required GetServicesUseCase getServices,
    required WatchActiveEventsUseCase watchEvents,
    required WatchLastCollectorRunUseCase watchRun,
  }) : _getServices = getServices,
       _watchEvents = watchEvents,
       _watchRun = watchRun,
       super(ServicesInitial());

  final GetServicesUseCase _getServices;
  final WatchActiveEventsUseCase _watchEvents;
  final WatchLastCollectorRunUseCase _watchRun;

  StreamSubscription<List<ServiceEvent>>? _eventsSub;
  StreamSubscription<CollectorRun?>? _runSub;
  Timer? _countdownTimer;

  List<MonitoredService> _services = [];
  List<ServiceEvent> _activeEvents = [];
  CollectorRun? _lastRun;
  bool _isActive = false;
  bool _isReconnecting = false;
  int _secondsLeft = 0;

  Future<void> load() => activate();

  Future<void> activate() async {
    _isActive = true;
    if (_eventsSub != null || _runSub != null) return;

    if (_services.isEmpty) {
      emit(ServicesLoading());
      try {
        _services = await _getServices.execute();
        _emitLoaded();
      } catch (e) {
        emit(ServicesError(e.toString()));
        return;
      }
      if (!_isActive || isClosed) return;
    }

    _eventsSub = _watchEvents.execute(onRetry: _onRetry).listen((events) {
      if (!_isActive) return;
      _activeEvents = events;
      _emitLoaded();
    });

    _runSub = _watchRun.execute(onRetry: _onRetry).listen((run) {
      if (!_isActive) return;
      _lastRun = run;
      _emitLoaded();
    });
    _emitLoaded();
  }

  Future<void> deactivate() async {
    _isActive = false;
    await _eventsSub?.cancel();
    await _runSub?.cancel();
    _eventsSub = null;
    _runSub = null;
    _stopCountdown();
  }

  void _onRetry(RetryState retryState) {
    switch (retryState) {
      case Retrying(:final backoff):
        _startCountdown(backoff);
      case Reconnected():
        _stopCountdown();
    }
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
    if (_services.isEmpty && state is! ServicesLoaded) return;
    emit(
      ServicesLoaded(
        services: _services,
        activeEvents: _activeEvents,
        lastRun: _lastRun,
        isReconnecting: _isReconnecting,
        reconnectingInSeconds: _isReconnecting ? _secondsLeft : null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await deactivate();
    _countdownTimer?.cancel();
    return super.close();
  }
}
