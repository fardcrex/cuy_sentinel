import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/stream_retry.dart';
import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../../feature/users/domain/entities/user_access_log.dart';
import '../../../feature/users/domain/entities/user_presence.dart';
import 'users_state.dart';

class UsersBloc extends Cubit<UsersState> {
  UsersBloc({
    required WatchPanelUsersUseCase watchUsers,
    required WatchAccessLogsUseCase watchAccessLogs,
    required WatchPresenceUseCase watchPresence,
  }) : _watchUsers = watchUsers,
       _watchAccessLogs = watchAccessLogs,
       _watchPresence = watchPresence,
       super(UsersInitial());

  final WatchPanelUsersUseCase _watchUsers;
  final WatchAccessLogsUseCase _watchAccessLogs;
  final WatchPresenceUseCase _watchPresence;

  StreamSubscription<List<PanelUser>>? _usersSub;
  StreamSubscription<List<UserAccessLog>>? _logsSub;
  StreamSubscription<List<UserPresence>>? _presenceSub;
  Timer? _countdownTimer;

  List<PanelUser> _users = [];
  List<UserAccessLog> _logs = [];
  List<UserPresence> _presences = [];
  bool _isReconnecting = false;
  int _secondsLeft = 0;
  bool _usersReady = false;

  void load() {
    emit(UsersLoading());

    _usersSub = _watchUsers.execute(onRetry: _onRetry).listen((u) {
      _users = u;
      _usersReady = true;
      _emitLoaded();
    }, onError: (Object e, StackTrace s) => emit(UsersError(e.toString())));

    _logsSub = _watchAccessLogs.execute(onRetry: _onRetry).listen((l) {
      _logs = l;
      _emitLoaded();
    }, onError: (Object e, StackTrace s) => emit(UsersError(e.toString())));

    _presenceSub = _watchPresence.execute().listen((presences) {
      _presences = presences;
      _emitLoaded();
    }, onError: (Object e, StackTrace s) => emit(UsersError(e.toString())));
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
    if (!_usersReady || isClosed) return;
    emit(
      UsersLoaded(
        users: _users,
        accessLogs: _logs,
        presences: _presences,
        isReconnecting: _isReconnecting,
        reconnectingInSeconds: _isReconnecting ? _secondsLeft : null,
      ),
    );
  }

  void changeRole(String userId, UserRole newRole) {
    _users = _users
        .map((u) => u.id == userId ? u.copyWith(role: newRole) : u)
        .toList();
    _emitLoaded();
  }

  @override
  Future<void> close() async {
    await _usersSub?.cancel();
    await _logsSub?.cancel();
    await _presenceSub?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
