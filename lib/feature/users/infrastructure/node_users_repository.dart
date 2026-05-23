import '../../../core/utils/stream_retry.dart';
import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/entities/user_presence.dart';
import '../domain/interfaces/i_users_repository.dart';

// Fase 2: implementar con Node.js API + Socket.IO
class NodeUsersRepository implements IUsersRepository {
  @override
  Stream<List<PanelUser>> watchUsers({void Function(RetryState)? onRetry}) =>
      Stream.error(UnimplementedError('NodeUsersRepository.watchUsers'));

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

  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) => throw UnimplementedError('NodeUsersRepository.logAccess');

  @override
  Future<void> updateSession(String userId, {required bool loggedIn}) =>
      throw UnimplementedError('NodeUsersRepository.updateSession');

  @override
  Stream<List<UserAccessLog>> watchAccessLogs({
    int limit = 50,
    void Function(RetryState)? onRetry,
  }) => Stream.error(UnimplementedError('NodeUsersRepository.watchAccessLogs'));

  @override
  Stream<List<UserPresence>> watchPresence() =>
      Stream.error(UnimplementedError('NodeUsersRepository.watchPresence'));

  @override
  Future<void> trackPresence({
    required String userId,
    required String deviceName,
    required String devicePlatform,
  }) => throw UnimplementedError('NodeUsersRepository.trackPresence');

  @override
  Future<void> untrackPresence() =>
      throw UnimplementedError('NodeUsersRepository.untrackPresence');
}
