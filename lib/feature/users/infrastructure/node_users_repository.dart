import 'dart:async';

import '../../../core/node/node_api_client.dart';
import '../../../core/utils/stream_retry.dart';
import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/entities/user_presence.dart';
import '../domain/interfaces/i_users_repository.dart';

class NodeUsersRepository implements IUsersRepository {
  final _client = NodeApiClient.instance;

  @override
  Future<List<PanelUser>> getUsers() async {
    final rows = await _client.get('/api/users') as List<dynamic>;
    return rows
        .map((r) => PanelUser.fromDynamic(r))
        .toList();
  }

  @override
  Future<PanelUser?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<PanelUser>> watchUsers({void Function(RetryState)? onRetry}) {
    late final StreamController<List<PanelUser>> controller;
    Timer? timer;

    Future<void> fetch() async {
      try {
        final users = await getUsers();
        if (!controller.isClosed) controller.add(users);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<List<PanelUser>>(
      onListen: () async {
        await fetch();
        timer = Timer.periodic(const Duration(seconds: 30), (_) => fetch());
      },
      onCancel: () {
        timer?.cancel();
        timer = null;
      },
    );

    return controller.stream;
  }

  @override
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) async {
    final rows = await _client.get(
      '/api/users/access-logs',
      params: {'limit': '$limit'},
    ) as List<dynamic>;
    return rows
        .map((r) => UserAccessLog.fromDynamic(r))
        .toList();
  }

  @override
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  }) async {
    final rows = await _client.get(
      '/api/users/access-logs',
      params: {'userId': userId, 'limit': '$limit'},
    ) as List<dynamic>;
    return rows
        .map((r) => UserAccessLog.fromDynamic(r))
        .toList();
  }

  @override
  Stream<List<UserAccessLog>> watchAccessLogs({
    int limit = 50,
    void Function(RetryState)? onRetry,
  }) {
    late final StreamController<List<UserAccessLog>> controller;
    Timer? timer;

    Future<void> fetch() async {
      try {
        final logs = await getAccessLogs(limit: limit);
        if (!controller.isClosed) controller.add(logs);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<List<UserAccessLog>>(
      onListen: () async {
        await fetch();
        timer = Timer.periodic(const Duration(seconds: 30), (_) => fetch());
      },
      onCancel: () {
        timer?.cancel();
        timer = null;
      },
    );

    return controller.stream;
  }

  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) async {
    await _client.post('/api/users/access-logs', {
      'userId': userId,
      'displayName': displayName,
      'action': action.toJson(),
      'deviceName': deviceName,
      'devicePlatform': devicePlatform,
    });
  }

  @override
  Future<void> updateSession(String userId, {required bool loggedIn}) async {
    // JWT expiry handles session tracking in Phase 2.
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _client.patch('/api/users/$userId/role', {'role': role.toJson()});
  }

  // Supabase Presence is not available in Phase 2.
  @override
  Stream<List<UserPresence>> watchPresence() => Stream.value([]);

  @override
  Future<void> trackPresence({
    required String userId,
    required String deviceName,
    required String devicePlatform,
    UserPresenceStatus status = UserPresenceStatus.active,
  }) async {}

  @override
  Future<void> untrackPresence() async {}
}
