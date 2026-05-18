import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/interfaces/i_users_repository.dart';

class WatchPanelUsersUseCase {
  const WatchPanelUsersUseCase(this._repository);

  final IUsersRepository _repository;

  Stream<List<PanelUser>> execute() => _repository.watchUsers();
}

class GetPanelUsersUseCase {
  const GetPanelUsersUseCase(this._repository);

  final IUsersRepository _repository;

  Future<List<PanelUser>> execute() => _repository.getUsers();
}

class GetAccessLogsUseCase {
  const GetAccessLogsUseCase(this._repository);

  final IUsersRepository _repository;

  Future<List<UserAccessLog>> execute({int limit = 50}) =>
      _repository.getAccessLogs(limit: limit);
}
