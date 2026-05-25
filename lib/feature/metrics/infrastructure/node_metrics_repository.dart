import 'dart:async';

import '../../../core/node/node_api_client.dart';
import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

class NodeMetricsRepository implements IMetricsRepository {
  final _client = NodeApiClient.instance;

  @override
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  }) {
    late final StreamController<List<Metric>> controller;
    List<Metric> current = [];

    void handleSocketEvent(dynamic data) {
      final metric = Metric.fromDynamic(data);
      if (metric.serviceId == serviceId) {
        current = [metric, ...current].take(limit).toList();
        if (!controller.isClosed) controller.add(current);
      }
    }

    controller = StreamController<List<Metric>>(
      onListen: () async {
        try {
          final rows = await _client.get(
            '/api/metrics/$serviceId',
            params: {'limit': '$limit'},
          ) as List<dynamic>;
          current = rows
              .map((r) => Metric.fromDynamic(r))
              .toList();
          if (!controller.isClosed) controller.add(current);
          _client.socket.on('metric', handleSocketEvent);
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
      },
      onCancel: () {
        _client.socket.off('metric', handleSocketEvent);
      },
    );

    return controller.stream;
  }

  @override
  Future<List<Metric>> getByRange({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client.get(
      '/api/metrics/$serviceId',
      params: {
        'limit': '500',
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    ) as List<dynamic>;
    return rows
        .map((r) => Metric.fromDynamic(r))
        .toList();
  }
}
