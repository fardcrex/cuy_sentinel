import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/interfaces/i_users_repository.dart';

// Fase 1: implementar con Supabase Realtime channel (postgres_changes UPDATE on users)
class SupabaseUsersRepository implements IUsersRepository {
  @override
  Stream<List<PanelUser>> watchUsers() => Stream.error(
    UnimplementedError('SupabaseUsersRepository.watchUsers'),
  );

  @override
  Future<List<PanelUser>> getUsers() =>
      throw UnimplementedError('SupabaseUsersRepository.getUsers');

  @override
  Future<PanelUser?> getUserById(String id) =>
      throw UnimplementedError('SupabaseUsersRepository.getUserById');

  @override
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) =>
      throw UnimplementedError('SupabaseUsersRepository.getAccessLogs');

  @override
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  }) => throw UnimplementedError(
    'SupabaseUsersRepository.getAccessLogsByUser',
  );
}
