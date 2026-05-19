import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc({
    required WatchPanelUsersUseCase watchUsers,
    required GetAccessLogsUseCase getAccessLogs,
  })  : _watchUsers = watchUsers,
        _getAccessLogs = getAccessLogs,
        super(UsersInitial()) {
    on<UsersWatchRequested>(_onWatchRequested);
    on<UserRoleChanged>(_onRoleChanged);
    on<UserDeactivated>(_onDeactivated);
  }

  final WatchPanelUsersUseCase _watchUsers;
  final GetAccessLogsUseCase _getAccessLogs;

  Future<void> _onWatchRequested(
    UsersWatchRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final logs = await _getAccessLogs.execute();
      await emit.forEach<List<PanelUser>>(
        _watchUsers.execute(),
        onData: (users) => UsersLoaded(
          users: users,
          accessLogs: logs,
        ),
        onError: (e, _) => UsersError(e.toString()),
      );
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  void _onRoleChanged(UserRoleChanged event, Emitter<UsersState> emit) {
    // Mutation not yet available in repository — wired in Fase 2
  }

  void _onDeactivated(UserDeactivated event, Emitter<UsersState> emit) {
    // Mutation not yet available in repository — wired in Fase 2
  }
}
