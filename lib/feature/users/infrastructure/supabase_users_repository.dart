import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/utils/stream_retry.dart';
import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/interfaces/i_users_repository.dart';

class SupabaseUsersRepository implements IUsersRepository {
  SupabaseUsersRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;
  supabase.RealtimeChannel? _presenceChannel;
  String? _trackedUserId;

  @override
  Stream<List<PanelUser>> watchUsers({
    void Function(RetryState)? onRetry,
  }) => retryStream(
        () => _client
            .from('users')
            .stream(primaryKey: ['id'])
            .order('display_name')
            .map((rows) => rows.map(PanelUser.fromJson).toList()),
        onRetry: onRetry,
      );

  @override
  Stream<List<UserAccessLog>> watchAccessLogs({
    int limit = 50,
    void Function(RetryState)? onRetry,
  }) => retryStream(
        () => _client
            .from('user_access_logs')
            .stream(primaryKey: ['id'])
            .order('timestamp', ascending: false)
            .map((rows) => rows.take(limit).map(UserAccessLog.fromJson).toList()),
        onRetry: onRetry,
      );

  @override
  Stream<Set<String>> watchPresence() => retryStream(_buildPresenceStream);

  Stream<Set<String>> _buildPresenceStream() async* {
    if (_presenceChannel != null) {
      await _client.removeChannel(_presenceChannel!);
      _presenceChannel = null;
    }

    final ctrl = StreamController<Set<String>>();

    _presenceChannel = _client.channel('panel:presence');
    _presenceChannel!.onPresenceSync((_) {
      if (!ctrl.isClosed) ctrl.add(_extractOnlineIds());
    });
    _presenceChannel!.subscribe((status, _) async {
      if (status == supabase.RealtimeSubscribeStatus.subscribed) {
        final uid = _trackedUserId;
        if (uid != null) await _presenceChannel?.track({'user_id': uid});
        if (!ctrl.isClosed) ctrl.add(_extractOnlineIds());
      } else if (status == supabase.RealtimeSubscribeStatus.channelError ||
          status == supabase.RealtimeSubscribeStatus.timedOut) {
        ctrl.addError(Exception('presence channel error — will retry'));
      }
    });

    ctrl.onCancel = () async {
      if (_presenceChannel != null) {
        await _client.removeChannel(_presenceChannel!);
        _presenceChannel = null;
      }
    };

    yield _extractOnlineIds();
    yield* ctrl.stream;
  }

  // presenceState() → List<SinglePresenceState>
  // each SinglePresenceState has presences: List<Presence>
  // each Presence has payload: Map<String, dynamic>
  Set<String> _extractOnlineIds() => (_presenceChannel?.presenceState() ?? [])
      .expand((s) => s.presences)
      .map((p) => p.payload['user_id'] as String? ?? '')
      .where((id) => id.isNotEmpty)
      .toSet();

  @override
  Future<void> trackPresence(String userId) async {
    _trackedUserId = userId;
    await _presenceChannel?.track({'user_id': userId});
  }

  @override
  Future<void> untrackPresence() async {
    _trackedUserId = null;
    await _presenceChannel?.untrack();
  }

  @override
  Future<List<PanelUser>> getUsers() async {
    final rows = await _client
        .from('users')
        .select()
        .order('display_name');
    return rows.map(PanelUser.fromJson).toList();
  }

  @override
  Future<PanelUser?> getUserById(String id) async {
    final rows = await _client
        .from('users')
        .select()
        .eq('id', id)
        .limit(1);
    if (rows.isEmpty) return null;
    return PanelUser.fromJson(rows.first);
  }

  @override
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) async {
    final rows = await _client
        .from('user_access_logs')
        .select()
        .order('timestamp', ascending: false)
        .limit(limit);
    return rows.map(UserAccessLog.fromJson).toList();
  }

  @override
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  }) async {
    final rows = await _client
        .from('user_access_logs')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .limit(limit);
    return rows.map(UserAccessLog.fromJson).toList();
  }

  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
  }) async {
    await _client.from('user_access_logs').insert({
      'user_id': userId,
      'display_name': displayName,
      'action': action.toJson(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> updateSession(String userId, {required bool loggedIn}) async {
    if (!loggedIn) return;
    await _client.from('users').update({
      'last_login': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }
}
