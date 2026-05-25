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
    required ChangeUserRoleUseCase changeUserRole,
  }) : _watchUsers = watchUsers,
       _watchAccessLogs = watchAccessLogs,
       _watchPresence = watchPresence,
       _changeUserRole = changeUserRole,
       super(UsersInitial());

  final WatchPanelUsersUseCase _watchUsers;
  final WatchAccessLogsUseCase _watchAccessLogs;
  final WatchPresenceUseCase _watchPresence;
  final ChangeUserRoleUseCase _changeUserRole;

  StreamSubscription<List<PanelUser>>? _usersSub;
  StreamSubscription<List<UserAccessLog>>? _logsSub;
  StreamSubscription<List<UserPresence>>? _presenceSub;
  Timer? _countdownTimer;

  List<PanelUser> _users = [];
  List<UserAccessLog> _logs = [];
  List<UserPresence> _presences = [];
  bool _isActive = false;
  bool _isReconnecting = false;
  int _secondsLeft = 0;
  bool _usersReady = false;

  Future<void> load() => activate();

  Future<void> activate() async {
    _isActive = true;
    if (_usersSub != null || _logsSub != null || _presenceSub != null) {
      return;
    }

    if (!_usersReady) {
      emit(UsersLoading());
    }

    _usersSub = _watchUsers.execute(onRetry: _onRetry).listen((u) {
      if (!_isActive) return;
      _users = u;
      _usersReady = true;
      _emitLoaded();
    }, onError: (Object e, StackTrace s) => emit(UsersError(e.toString())));

    _logsSub = _watchAccessLogs.execute(onRetry: _onRetry).listen((l) {
      if (!_isActive) return;
      _logs = l;
      _emitLoaded();
    }, onError: (Object e, StackTrace s) => emit(UsersError(e.toString())));

    _presenceSub = _watchPresence.execute().listen((presences) {
      if (!_isActive) return;
      _presences = presences;
      _emitLoaded();
    }, onError: (Object e, StackTrace s) => emit(UsersError(e.toString())));
  }

  Future<void> deactivate() async {
    _isActive = false;
    await _usersSub?.cancel();
    await _logsSub?.cancel();
    await _presenceSub?.cancel();
    _usersSub = null;
    _logsSub = null;
    _presenceSub = null;
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

  Future<void> changeRole(String userId, UserRole newRole) async {
    await _changeUserRole.execute(userId: userId, role: newRole);
    _replaceUserRole(userId, newRole);
  }

  void _replaceUserRole(String userId, UserRole newRole) {
    _users = _users
        .map((u) => u.id == userId ? u.copyWith(role: newRole) : u)
        .toList();
    _emitLoaded();
  }

  @override
  Future<void> close() async {
    await deactivate();
    _countdownTimer?.cancel();
    return super.close();
  }
}
