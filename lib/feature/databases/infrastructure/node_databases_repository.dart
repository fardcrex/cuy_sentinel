import 'dart:async';

import '../../../core/node/node_api_client.dart';
import '../../../core/utils/stream_retry.dart';
import '../domain/entities/database_health.dart';
import '../domain/entities/database_instance.dart';
import '../domain/entities/table_stats.dart';
import '../domain/interfaces/i_databases_repository.dart';

class NodeDatabasesRepository implements IDatabasesRepository {
  final _client = NodeApiClient.instance;

  static const _patroniCluster = DatabaseInstance(
    id: 'postgresql-primary-phase2',
    name: 'PostgreSQL Patroni',
    provider: DatabaseProvider.postgresql,
    phase: DatabasePhase.phase2,
    enabled: true,
    host: 'localhost',
    port: 5432,
    database: 'postgres',
    description: 'Clúster Patroni vía HAProxy — nodo activo',
  );

  @override
  Future<List<DatabaseInstance>> getInstances() async => [_patroniCluster];

  @override
  Future<DatabaseHealth> getHealth(String instanceId) async {
    final data =
        await _client.get('/api/db/health', params: {'instanceId': instanceId})
            as Map<String, dynamic>;
    return DatabaseHealth.fromJson(data);
  }

  @override
  Stream<DatabaseHealth> watchHealth(
    String instanceId, {
    void Function(RetryState)? onRetry,
  }) {
    late final StreamController<DatabaseHealth> controller;

    void handler(dynamic data) {
      final health = DatabaseHealth.fromDynamic(data);
      if (health.instanceId == instanceId && !controller.isClosed) {
        controller.add(health);
      }
    }

    controller = StreamController<DatabaseHealth>(
      onListen: () async {
        // Carga inicial vía HTTP para no esperar 30 s al primer dato
        try {
          final health = await getHealth(instanceId);
          if (!controller.isClosed) controller.add(health);
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
        _client.socket.on('db_health', handler);
      },
      onCancel: () => _client.socket.off('db_health', handler),
    );

    return controller.stream;
  }

  @override
  Future<List<TableStats>> getTableStats(String instanceId) async {
    final rows =
        await _client.get('/api/db/tables', params: {'instanceId': instanceId})
            as List<dynamic>;

    return rows.map(TableStats.fromDynamic).toList();
  }
}
