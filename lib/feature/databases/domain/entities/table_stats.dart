/// Per-table statistics collected from pg_stat_user_tables.
class TableStats {
  const TableStats({
    required this.instanceId,
    required this.tableName,
    required this.liveRows,
    required this.deadRows,
    required this.sizeMb,
    required this.seqScans,
    required this.indexScans,
    this.lastAnalyzed,
    this.lastVacuumed,
    required this.collectedAt,
  });

  final String instanceId;
  final String tableName;

  /// n_live_tup — approximate live row count (no need for COUNT(*))
  final int liveRows;

  /// n_dead_tup — rows pending VACUUM. High values indicate maintenance needed.
  final int deadRows;

  /// pg_total_relation_size(tableName) / 1048576
  final int sizeMb;

  /// seq_scan — number of sequential scans (no index used)
  final int seqScans;

  /// idx_scan — number of index scans
  final int indexScans;

  /// last_analyze
  final DateTime? lastAnalyzed;

  /// last_vacuum
  final DateTime? lastVacuumed;

  final DateTime collectedAt;

  /// Ratio of index scans vs total scans. Values > 0.9 are healthy.
  double? get indexScanRatio {
    final total = seqScans + indexScans;
    if (total == 0) return null;
    return indexScans / total;
  }

  factory TableStats.fromDynamic(dynamic data) =>
      TableStats.fromJson(Map<String, dynamic>.from(data as Map));

  factory TableStats.fromJson(Map<String, dynamic> json) => TableStats(
    instanceId: json['instance_id'] as String,
    tableName: json['table_name'] as String,
    liveRows: (json['live_rows'] as int?) ?? 0,
    deadRows: (json['dead_rows'] as int?) ?? 0,
    sizeMb: (json['size_mb'] as int?) ?? 0,
    seqScans: (json['seq_scans'] as int?) ?? 0,
    indexScans: (json['index_scans'] as int?) ?? 0,
    lastAnalyzed: json['last_analyzed'] != null
        ? DateTime.parse(json['last_analyzed'] as String)
        : null,
    lastVacuumed: json['last_vacuumed'] != null
        ? DateTime.parse(json['last_vacuumed'] as String)
        : null,
    collectedAt: DateTime.parse(json['collected_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'instance_id': instanceId,
    'table_name': tableName,
    'live_rows': liveRows,
    'dead_rows': deadRows,
    'size_mb': sizeMb,
    'seq_scans': seqScans,
    'index_scans': indexScans,
    'last_analyzed': lastAnalyzed?.toIso8601String(),
    'last_vacuumed': lastVacuumed?.toIso8601String(),
    'collected_at': collectedAt.toIso8601String(),
  };
}
