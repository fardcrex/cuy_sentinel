import 'dart:async';

import '../../../core/node/node_api_client.dart';
import '../../../core/utils/stream_retry.dart';
import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

class NodeAlertsRepository implements IAlertsRepository {
  final _client = NodeApiClient.instance;

  // Carga inicial + escucha 'active_alerts' (lista completa que el server empuja
  // cada 30 s y también al resolver una alerta).
  @override
  Stream<List<AlertEvent>> watchActiveAlerts({
    void Function(RetryState)? onRetry,
  }) {
    late final StreamController<List<AlertEvent>> controller;

    void handler(dynamic data) {
      final alerts = (data as List<dynamic>)
          .map((r) => AlertEvent.fromDynamic(r))
          .toList();
      if (!controller.isClosed) controller.add(alerts);
    }

    controller = StreamController<List<AlertEvent>>(
      onListen: () async {
        try {
          final rows = await _client.get('/api/alerts') as List<dynamic>;
          final alerts = rows.map((r) => AlertEvent.fromDynamic(r)).toList();
          if (!controller.isClosed) controller.add(alerts);
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
        _client.socket.on('active_alerts', handler);
      },
      onCancel: () => _client.socket.off('active_alerts', handler),
    );

    return controller.stream;
  }

  // Escucha 'alert' — el server emite un objeto individual cada vez que el
  // colector inserta una nueva alerta (vía pg_notify → Socket.IO).
  @override
  Stream<AlertEvent> watchAlertInserts({void Function()? onSubscribed}) {
    late final StreamController<AlertEvent> controller;

    void handler(dynamic data) {
      final event = AlertEvent.fromDynamic(data);
      if (!event.resolved && !controller.isClosed) controller.add(event);
    }

    controller = StreamController<AlertEvent>(
      onListen: () {
        onSubscribed?.call();
        _client.socket.on('alert', handler);
      },
      onCancel: () => _client.socket.off('alert', handler),
    );

    return controller.stream;
  }

  @override
  Future<List<AlertEvent>> getAlertsSince(DateTime since) async {
    final rows =
        await _client.get(
              '/api/alerts',
              params: {'since': since.toUtc().toIso8601String()},
            )
            as List<dynamic>;
    return rows.map(AlertEvent.fromDynamic).toList();
  }

  @override
  Future<List<AlertEvent>> getAlertHistory({int limit = 50}) async {
    final rows =
        await _client.get('/api/alerts/history', params: {'limit': '$limit'})
            as List<dynamic>;
    return rows.map(AlertEvent.fromDynamic).toList();
  }

  @override
  Future<void> resolveAlert(String alertId) async {
    await _client.patch('/api/alerts/$alertId/resolve');
    // El server emite 'active_alerts' actualizado; watchActiveAlerts lo recibe.
  }

  @override
  Future<List<AlertThreshold>> getThresholds() async {
    try {
      final rows = await _client.get('/api/alerts/thresholds') as List<dynamic>;
      return rows.map(AlertThreshold.fromDynamic).toList();
    } catch (_) {
      return [];
    }
  }
}
