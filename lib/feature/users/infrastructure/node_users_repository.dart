import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/interfaces/i_users_repository.dart';

// Fase 2: implementar con Node.js API + Socket.IO
class NodeUsersRepository implements IUsersRepository {
  @override
  Stream<List<PanelUser>> watchUsers() => Stream.error(
    UnimplementedError('NodeUsersRepository.watchUsers'),
  );

  @override
  Future<List<PanelUser>> getUsers() =>
      throw UnimplementedError('NodeUsersRepository.getUsers');

  @override
  Future<PanelUser?> getUserById(String id) =>
      throw UnimplementedError('NodeUsersRepository.getUserById');

  @override
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) =>
      throw UnimplementedError('NodeUsersRepository.getAccessLogs');

  @override
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  }) => throw UnimplementedError('NodeUsersRepository.getAccessLogsByUser');
}
