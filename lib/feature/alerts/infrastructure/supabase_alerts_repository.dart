import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/utils/stream_retry.dart';

import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

class SupabaseAlertsRepository implements IAlertsRepository {
  SupabaseAlertsRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  @override
  Stream<List<AlertEvent>> watchActiveAlerts({
    void Function(RetryState)? onRetry,
  }) => retryStream(
        () => _client
            .from('alert_events')
            .stream(primaryKey: ['id'])
            .eq('resolved', false)
            .order('triggered_at', ascending: false)
            .map((rows) => rows.map(AlertEvent.fromJson).toList()),
        onRetry: onRetry,
      );

  @override
  Stream<AlertEvent> watchAlertInserts({void Function()? onSubscribed}) =>
      retryStream(() => _buildAlertInsertsStream(onSubscribed: onSubscribed));

  Stream<AlertEvent> _buildAlertInsertsStream({void Function()? onSubscribed}) {
    late final supabase.RealtimeChannel channel;
    final controller = StreamController<AlertEvent>(
      onCancel: () => _client.removeChannel(channel),
    );
    channel = _client
        .channel('alert_inserts')
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'alert_events',
          callback: (payload) {
            if (controller.isClosed) return;
            final event = AlertEvent.fromJson(payload.newRecord);
            if (!event.resolved) controller.add(event);
          },
        )
        .subscribe((status, _) {
          if (status == supabase.RealtimeSubscribeStatus.subscribed) {
            onSubscribed?.call();
          }
          if (status == supabase.RealtimeSubscribeStatus.channelError ||
              status == supabase.RealtimeSubscribeStatus.timedOut) {
            controller.addError(Exception('alert_inserts channel error'));
          }
        });
    return controller.stream;
  }

  @override
  Future<List<AlertEvent>> getAlertsSince(DateTime since) async {
    final rows = await _client
        .from('alert_events')
        .select()
        .gt('triggered_at', since.toUtc().toIso8601String())
        .eq('resolved', false)
        .order('triggered_at');
    return rows.map(AlertEvent.fromJson).toList();
  }

  @override
  Future<List<AlertThreshold>> getThresholds() async {
    try {
      final rows = await _client
          .from('alert_thresholds')
          .select()
          .eq('enabled', true)
          .order('metric_name');
      return rows.map(AlertThreshold.fromJson).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<AlertEvent>> getAlertHistory({int limit = 50}) async {
    final rows = await _client
        .from('alert_events')
        .select()
        .order('triggered_at', ascending: false)
        .limit(limit);
    return rows.map(AlertEvent.fromJson).toList();
  }

  @override
  Future<void> resolveAlert(String alertId) async {
    await _client
        .from('alert_events')
        .update({
          'resolved': true,
          'resolved_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', alertId);
  }
}
