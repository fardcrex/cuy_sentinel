import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/utils/stream_retry.dart';
import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/entities/user_presence.dart';
import '../domain/interfaces/i_users_repository.dart';

class SupabaseUsersRepository implements IUsersRepository {
  SupabaseUsersRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;
  supabase.RealtimeChannel? _presenceChannel;
  Future<void>? _presenceSetup;
  String? _trackedUserId;
  String? _trackedDeviceName;
  String? _trackedDevicePlatform;
  final _presenceListeners = <StreamController<List<UserPresence>>>{};

  @override
  Stream<List<PanelUser>> watchUsers({void Function(RetryState)? onRetry}) =>
      retryStream(
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
  Stream<List<UserPresence>> watchPresence() =>
      retryStream(_buildPresenceStream);

  Stream<List<UserPresence>> _buildPresenceStream() async* {
    final ctrl = StreamController<List<UserPresence>>();
    _presenceListeners.add(ctrl);

    ctrl.onCancel = () async {
      _presenceListeners.remove(ctrl);
    };

    await _ensurePresenceChannel();
    yield _extractPresences();
    yield* ctrl.stream;
  }

  Future<void> _ensurePresenceChannel() {
    final setup = _presenceSetup;
    if (setup != null) return setup;

    final completer = Completer<void>();
    _presenceSetup = completer.future;

    _presenceChannel = _client.channel('panel:presence');
    _presenceChannel!.onPresenceSync((_) => _emitPresence());
    _presenceChannel!.subscribe((status, _) async {
      if (status == supabase.RealtimeSubscribeStatus.subscribed) {
        final uid = _trackedUserId;
        if (uid != null) await _trackCurrentPresence();
        _emitPresence();
        if (!completer.isCompleted) completer.complete();
      } else if (status == supabase.RealtimeSubscribeStatus.channelError ||
          status == supabase.RealtimeSubscribeStatus.timedOut) {
        final error = Exception('presence channel error — will retry');
        _emitPresenceError(error);
        await _resetPresenceChannel();
        if (!completer.isCompleted) completer.completeError(error);
      }
    });

    return completer.future;
  }

  Future<void> _resetPresenceChannel() async {
    final channel = _presenceChannel;
    _presenceChannel = null;
    _presenceSetup = null;
    if (channel != null) await _client.removeChannel(channel);
  }

  Future<void> _trackCurrentPresence() async {
    final userId = _trackedUserId;
    final deviceName = _trackedDeviceName;
    final devicePlatform = _trackedDevicePlatform;
    if (userId == null || deviceName == null || devicePlatform == null) return;
    await _presenceChannel?.track({
      'user_id': userId,
      'device_name': deviceName,
      'device_platform': devicePlatform,
    });
  }

  void _emitPresence() {
    final presences = _extractPresences();
    for (final listener in List.of(_presenceListeners)) {
      if (!listener.isClosed) listener.add(presences);
    }
  }

  void _emitPresenceError(Object error) {
    for (final listener in List.of(_presenceListeners)) {
      if (!listener.isClosed) listener.addError(error);
    }
  }

  List<UserPresence> _extractPresences() =>
      (_presenceChannel?.presenceState() ?? [])
          .expand((s) => s.presences)
          .map((p) {
            final payload = p.payload;
            final userId = payload['user_id'] as String? ?? '';
            final deviceName = payload['device_name'] as String? ?? '';
            final devicePlatform = payload['device_platform'] as String? ?? '';
            if (userId.isEmpty ||
                deviceName.isEmpty ||
                devicePlatform.isEmpty) {
              return null;
            }
            return UserPresence(
              userId: userId,
              deviceName: deviceName,
              devicePlatform: devicePlatform,
            );
          })
          .nonNulls
          .toList();

  @override
  Future<void> trackPresence({
    required String userId,
    required String deviceName,
    required String devicePlatform,
  }) async {
    _trackedUserId = userId;
    _trackedDeviceName = deviceName;
    _trackedDevicePlatform = devicePlatform;
    await _ensurePresenceChannel();
    await _trackCurrentPresence();
    _emitPresence();
  }

  @override
  Future<void> untrackPresence() async {
    _trackedUserId = null;
    _trackedDeviceName = null;
    _trackedDevicePlatform = null;
    await _presenceChannel?.untrack();
    await _resetPresenceChannel();
    _emitPresence();
  }

  @override
  Future<List<PanelUser>> getUsers() async {
    final rows = await _client.from('users').select().order('display_name');
    return rows.map(PanelUser.fromJson).toList();
  }

  @override
  Future<PanelUser?> getUserById(String id) async {
    final rows = await _client.from('users').select().eq('id', id).limit(1);
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
    String? deviceName,
    String? devicePlatform,
  }) async {
    await _client.from('user_access_logs').insert({
      'user_id': userId,
      'display_name': displayName,
      'action': action.toJson(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'device_name': deviceName,
      'device_platform': devicePlatform,
    });
  }

  @override
  Future<void> updateSession(String userId, {required bool loggedIn}) async {
    if (!loggedIn) return;
    await _client
        .from('users')
        .update({'last_login': DateTime.now().toUtc().toIso8601String()})
        .eq('id', userId);
  }
}
