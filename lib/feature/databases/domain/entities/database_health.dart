/// Real-time health snapshot for one database instance.
/// All fields collected via SQL queries (see queries below).
class DatabaseHealth {
  const DatabaseHealth({
    required this.instanceId,
    required this.latencyMs,
    required this.storageMb,
    required this.activeConnections,
    required this.cacheHitPercent,
    required this.totalTables,
    required this.totalRows,
    this.lastWriteAt,
    required this.collectedAt,
  });

  final String instanceId;

  /// Round-trip of `SELECT 1` — measures network + query overhead.
  final int latencyMs;

  /// `SELECT pg_database_size(current_database()) / 1048576`
  final int storageMb;

  /// `SELECT count(*) FROM pg_stat_activity WHERE state = 'active'`
  final int activeConnections;

  /// `round(blks_hit * 100.0 / nullif(blks_hit + blks_read, 0), 1)`
  /// from pg_stat_database. Values near 99% are healthy.
  final double cacheHitPercent;

  /// `SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'`
  final int totalTables;

  /// `SELECT sum(n_live_tup) FROM pg_stat_user_tables` (approximate)
  final int totalRows;

  /// `SELECT max(collected_at) FROM metrics` — last time the collector wrote.
  final DateTime? lastWriteAt;

  final DateTime collectedAt;

  factory DatabaseHealth.fromDynamic(dynamic data) =>
      DatabaseHealth.fromJson(Map<String, dynamic>.from(data as Map));

  factory DatabaseHealth.fromJson(Map<String, dynamic> json) => DatabaseHealth(
    instanceId: json['instance_id'] as String,
    latencyMs: json['latency_ms'] as int,
    storageMb: json['storage_mb'] as int,
    activeConnections: json['active_connections'] as int,
    cacheHitPercent: (json['cache_hit_percent'] as num).toDouble(),
    totalTables: json['total_tables'] as int,
    totalRows: json['total_rows'] as int,
    lastWriteAt: json['last_write_at'] != null
        ? DateTime.parse(json['last_write_at'] as String)
        : null,
    collectedAt: DateTime.parse(json['collected_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'instance_id': instanceId,
    'latency_ms': latencyMs,
    'storage_mb': storageMb,
    'active_connections': activeConnections,
    'cache_hit_percent': cacheHitPercent,
    'total_tables': totalTables,
    'total_rows': totalRows,
    'last_write_at': lastWriteAt?.toIso8601String(),
    'collected_at': collectedAt.toIso8601String(),
  };
}
