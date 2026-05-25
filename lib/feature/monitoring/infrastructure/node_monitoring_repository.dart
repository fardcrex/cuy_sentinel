import 'dart:async';

import '../../../core/node/node_api_client.dart';
import '../../../core/utils/stream_retry.dart';
import '../domain/entities/collector_run.dart';
import '../domain/entities/monitored_service.dart';
import '../domain/entities/service_event.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class NodeMonitoringRepository implements IMonitoringRepository {
  final _client = NodeApiClient.instance;

  @override
  Future<List<MonitoredService>> getServices() async {
    final rows = await _client.get('/api/services') as List<dynamic>;
    return rows
        .map((r) => MonitoredService.fromDynamic(r))
        .toList();
  }

  @override
  Future<MonitoredService?> getServiceById(String id) async {
    final services = await getServices();
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  }) async {
    final rows = await _client.get(
      '/api/monitoring/events',
      params: {'serviceId': serviceId, 'limit': '$limit'},
    ) as List<dynamic>;
    return rows
        .map((r) => ServiceEvent.fromDynamic(r))
        .toList();
  }

  @override
  Future<List<ServiceEvent>> getRecentServiceEvents({int limit = 30}) async {
    final rows = await _client.get(
      '/api/monitoring/events/recent',
      params: {'limit': '$limit'},
    ) as List<dynamic>;
    return rows
        .map((r) => ServiceEvent.fromDynamic(r))
        .toList();
  }

  // Carga inicial + escucha 'active_events' (lista completa que el server empuja
  // cada 30 s y también cuando un servicio cae o se recupera).
  @override
  Stream<List<ServiceEvent>> watchActiveEvents({
    void Function(RetryState)? onRetry,
  }) {
    late final StreamController<List<ServiceEvent>> controller;

    void handler(dynamic data) {
      final events = (data as List<dynamic>)
          .map((r) => ServiceEvent.fromDynamic(r))
          .toList();
      if (!controller.isClosed) controller.add(events);
    }

    controller = StreamController<List<ServiceEvent>>(
      onListen: () async {
        try {
          final rows = await _client.get('/api/monitoring/events/active') as List<dynamic>;
          final events = rows
              .map((r) => ServiceEvent.fromDynamic(r))
              .toList();
          if (!controller.isClosed) controller.add(events);
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
        _client.socket.on('active_events', handler);
      },
      onCancel: () => _client.socket.off('active_events', handler),
    );

    return controller.stream;
  }

  @override
  Future<List<CollectorRun>> getCollectorRuns({int limit = 50}) async {
    final rows = await _client.get(
      '/api/monitoring/collector',
      params: {'limit': '$limit'},
    ) as List<dynamic>;
    return rows
        .map((r) => CollectorRun.fromDynamic(r))
        .toList();
  }

  // Carga inicial + escucha 'collector_run' — el server emite un objeto
  // individual cada vez que el colector Go termina una pasada de polling.
  @override
  Stream<CollectorRun?> watchLastCollectorRun({
    void Function(RetryState)? onRetry,
  }) {
    late final StreamController<CollectorRun?> controller;

    void handler(dynamic data) {
      final run = CollectorRun.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
      if (!controller.isClosed) controller.add(run);
    }

    controller = StreamController<CollectorRun?>(
      onListen: () async {
        try {
          final runs = await getCollectorRuns(limit: 1);
          if (!controller.isClosed) {
            controller.add(runs.isEmpty ? null : runs.first);
          }
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
        _client.socket.on('collector_run', handler);
      },
      onCancel: () => _client.socket.off('collector_run', handler),
    );

    return controller.stream;
  }
}
