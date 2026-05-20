import 'dart:math' as math;

import '../../../core/utils/stream_retry.dart';
import '../domain/entities/database_health.dart';
import '../domain/entities/database_instance.dart';
import '../domain/entities/table_stats.dart';
import '../domain/interfaces/i_databases_repository.dart';

class InMemoryDatabasesRepository implements IDatabasesRepository {
  static const _instances = [
    DatabaseInstance.passboltSupabase,
    DatabaseInstance.postgresqlPrimary,
    DatabaseInstance.postgresqlReplica,
  ];

  static final _tableStats = [
    TableStats(
      instanceId: 'supabase-phase1',
      tableName: 'metrics',
      liveRows: 12540,
      deadRows: 0,
      sizeMb: 2,
      seqScans: 4,
      indexScans: 8821,
      lastAnalyzed: DateTime.now().subtract(const Duration(hours: 1)),
      lastVacuumed: DateTime.now().subtract(const Duration(hours: 6)),
      collectedAt: DateTime.now(),
    ),
    TableStats(
      instanceId: 'supabase-phase1',
      tableName: 'collector_runs',
      liveRows: 150,
      deadRows: 0,
      sizeMb: 0,
      seqScans: 2,
      indexScans: 148,
      lastAnalyzed: DateTime.now().subtract(const Duration(hours: 1)),
      lastVacuumed: DateTime.now().subtract(const Duration(hours: 6)),
      collectedAt: DateTime.now(),
    ),
    TableStats(
      instanceId: 'supabase-phase1',
      tableName: 'service_events',
      liveRows: 3,
      deadRows: 0,
      sizeMb: 0,
      seqScans: 6,
      indexScans: 12,
      collectedAt: DateTime.now(),
    ),
    TableStats(
      instanceId: 'supabase-phase1',
      tableName: 'monitored_services',
      liveRows: 2,
      deadRows: 0,
      sizeMb: 0,
      seqScans: 1,
      indexScans: 298,
      collectedAt: DateTime.now(),
    ),
    TableStats(
      instanceId: 'supabase-phase1',
      tableName: 'users',
      liveRows: 3,
      deadRows: 0,
      sizeMb: 0,
      seqScans: 0,
      indexScans: 54,
      collectedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<DatabaseInstance>> getInstances() async =>
      List.of(_instances);

  @override
  Future<DatabaseHealth> getHealth(String instanceId) async =>
      _buildHealth(instanceId, 0, math.Random(instanceId.hashCode));

  @override
  Stream<DatabaseHealth> watchHealth(
    String instanceId, {
    void Function(RetryState)? onRetry,
  }) async* {
    final rng = math.Random(instanceId.hashCode);
    var tick = 0;
    while (true) {
      yield _buildHealth(instanceId, tick, rng);
      tick++;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  Future<List<TableStats>> getTableStats(String instanceId) async =>
      _tableStats.where((t) => t.instanceId == instanceId).toList();

  static DatabaseHealth _buildHealth(
    String instanceId,
    int tick,
    math.Random rng,
  ) {
    final latency = 28 + (rng.nextInt(7) - 3);
    final connections = 3 + (tick % 3 == 0 ? 1 : 0);
    final totalRows = 12698 + tick * 2;
    return DatabaseHealth(
      instanceId: instanceId,
      latencyMs: latency,
      storageMb: 124,
      activeConnections: connections,
      cacheHitPercent: 99.0 + rng.nextDouble() * 0.9,
      totalTables: 5,
      totalRows: totalRows,
      lastWriteAt: DateTime.now().subtract(const Duration(minutes: 3)),
      collectedAt: DateTime.now(),
    );
  }
}
