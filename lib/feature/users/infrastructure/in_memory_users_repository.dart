import '../../../core/utils/stream_retry.dart';
import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/interfaces/i_users_repository.dart';

class InMemoryUsersRepository implements IUsersRepository {
  static final _now = DateTime.now();

  static final _users = [
    PanelUser(
      id: 'usr-jair',
      email: 'jair@cuy-sentinel.local',
      displayName: 'Jair Conislla',
      role: UserRole.master,
      lastLogin: _now.subtract(const Duration(minutes: 12)),
      sessionExpiresAt: _now.add(const Duration(hours: 8)),
      createdAt: DateTime(2025, 3, 1),
    ),
    PanelUser(
      id: 'usr-daniel',
      email: 'daniel@cuy-sentinel.local',
      displayName: 'Daniel Rojas',
      role: UserRole.viewer,
      lastLogin: _now.subtract(const Duration(hours: 3, minutes: 40)),
      sessionExpiresAt: _now.subtract(const Duration(hours: 2)),
      createdAt: DateTime(2025, 3, 1),
    ),
    PanelUser(
      id: 'usr-jheampierre',
      email: 'jheampierre@cuy-sentinel.local',
      displayName: 'Jheampierre Ralli',
      role: UserRole.viewer,
      lastLogin: _now.subtract(const Duration(days: 1, hours: 2)),
      createdAt: DateTime(2025, 3, 1),
    ),
  ];

  static final _logs = [
    UserAccessLog(
      id: 'log-001',
      userId: 'usr-jair',
      displayName: 'Jair Conislla',
      action: UserAccessAction.login,
      timestamp: _now.subtract(const Duration(minutes: 12)),
      deviceName: 'Chrome 124 · macOS Sonoma',
      devicePlatform: 'web',
    ),
    UserAccessLog(
      id: 'log-002',
      userId: 'usr-daniel',
      displayName: 'Daniel Rojas',
      action: UserAccessAction.logout,
      timestamp: _now.subtract(const Duration(hours: 1, minutes: 30)),
      deviceName: 'Pixel 7 · Android 14',
      devicePlatform: 'android',
    ),
    UserAccessLog(
      id: 'log-003',
      userId: 'usr-daniel',
      displayName: 'Daniel Rojas',
      action: UserAccessAction.login,
      timestamp: _now.subtract(const Duration(hours: 3, minutes: 40)),
      deviceName: 'Pixel 7 · Android 14',
      devicePlatform: 'android',
    ),
    UserAccessLog(
      id: 'log-004',
      userId: 'usr-jheampierre',
      displayName: 'Jheampierre Ralli',
      action: UserAccessAction.logout,
      timestamp: _now.subtract(const Duration(days: 1, hours: 2)),
      deviceName: 'iPhone 15 · iOS 17.4',
      devicePlatform: 'ios',
    ),
    UserAccessLog(
      id: 'log-005',
      userId: 'usr-jheampierre',
      displayName: 'Jheampierre Ralli',
      action: UserAccessAction.login,
      timestamp: _now.subtract(const Duration(days: 1, hours: 3, minutes: 15)),
      deviceName: 'iPhone 15 · iOS 17.4',
      devicePlatform: 'ios',
    ),
  ];

  @override
  Stream<List<PanelUser>> watchUsers({
    void Function(RetryState)? onRetry,
  }) async* {
    while (true) {
      yield List.of(_users);
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  @override
  Stream<List<UserAccessLog>> watchAccessLogs({
    int limit = 50,
    void Function(RetryState)? onRetry,
  }) async* {
    yield _logs.take(limit).toList();
  }

  @override
  Stream<Set<String>> watchPresence() async* {
    yield _users
        .where((u) => u.sessionExpiresAt?.isAfter(DateTime.now()) ?? false)
        .map((u) => u.id)
        .toSet();
  }

  @override
  Future<void> trackPresence(String userId) async {}

  @override
  Future<void> untrackPresence() async {}

  @override
  Future<List<PanelUser>> getUsers() async => List.of(_users);

  @override
  Future<PanelUser?> getUserById(String id) async =>
      _users.where((u) => u.id == id).firstOrNull;

  @override
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) async =>
      _logs.take(limit).toList();

  @override
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  }) async =>
      _logs.where((l) => l.userId == userId).take(limit).toList();

  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) async {}

  @override
  Future<void> updateSession(String userId, {required bool loggedIn}) async {}
}
