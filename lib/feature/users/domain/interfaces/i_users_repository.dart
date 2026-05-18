import '../entities/panel_user.dart';
import '../entities/user_access_log.dart';

abstract interface class IUsersRepository {
  /// Real-time stream — emits when a user's online status or session changes.
  Stream<List<PanelUser>> watchUsers();

  Future<List<PanelUser>> getUsers();
  Future<PanelUser?> getUserById(String id);
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50});
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  });
}
