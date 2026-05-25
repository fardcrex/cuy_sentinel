import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/stream_retry.dart';
import '../../../../feature/databases/application/get_database_health_use_case.dart';
import '../../../../feature/databases/domain/entities/database_health.dart';
import '../../../../feature/databases/domain/entities/table_stats.dart';
import 'databases_state.dart';

class DatabasesCubit extends Cubit<DatabasesState> {
  DatabasesCubit({
    required WatchDatabaseHealthUseCase watchHealth,
    required GetTableStatsUseCase getTableStats,
  }) : _watchHealth = watchHealth,
       _getTableStats = getTableStats,
       super(DatabasesInitial());

  final WatchDatabaseHealthUseCase _watchHealth;
  final GetTableStatsUseCase _getTableStats;

  StreamSubscription<DatabaseHealth>? _sub;
  Timer? _countdownTimer;

  static const _instanceId = 'supabase-phase1';

  List<TableStats> _tableStats = [];
  DatabaseHealth? _health;
  bool _isActive = false;
  bool _isReconnecting = false;
  int _secondsLeft = 0;

  Future<void> load() => activate();

  Future<void> activate() async {
    _isActive = true;
    if (_sub != null) return;

    if (_tableStats.isEmpty) {
      emit(DatabasesLoading());
      try {
        _tableStats = await _getTableStats.execute(_instanceId);
      } catch (e) {
        emit(DatabasesError(e.toString()));
        return;
      }
      if (!_isActive || isClosed) return;
    }

    _sub = _watchHealth.execute(_instanceId, onRetry: _onRetry).listen((
      health,
    ) {
      if (!_isActive) return;
      _health = health;
      _emitLoaded();
    }, onError: (e) => emit(DatabasesError(e.toString())));
    _emitLoaded();
  }

  Future<void> deactivate() async {
    _isActive = false;
    await _sub?.cancel();
    _sub = null;
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
    final health = _health;
    if (health == null || isClosed) return;
    emit(
      DatabasesLoaded(
        health: health,
        tableStats: _tableStats,
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
