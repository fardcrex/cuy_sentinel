import '../../../../core/utils/stream_retry.dart';
import '../entities/panel_user.dart';
import '../entities/user_access_log.dart';

abstract interface class IUsersRepository {
  /// Real-time stream — emits when a user's online status or session changes.
  Stream<List<PanelUser>> watchUsers({void Function(RetryState)? onRetry});

  /// Real-time stream — emits whenever a new access log is inserted.
  Stream<List<UserAccessLog>> watchAccessLogs({
    int limit = 50,
    void Function(RetryState)? onRetry,
  });

  /// Real-time stream — emits the set of user IDs currently online via
  /// WebSocket presence. No DB writes involved.
  Stream<Set<String>> watchPresence();

  Future<List<PanelUser>> getUsers();
  Future<PanelUser?> getUserById(String id);
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50});
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  });

  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  });

  /// Updates last_login on login. Presence (isOnline) is managed by the
  /// WebSocket channel, not by session_expires_at.
  Future<void> updateSession(String userId, {required bool loggedIn});

  /// Announces the current user as present on the shared presence channel.
  /// Must be called after login.
  Future<void> trackPresence(String userId);

  /// Removes the current user from the presence channel.
  /// Must be called before logout.
  Future<void> untrackPresence();
}
