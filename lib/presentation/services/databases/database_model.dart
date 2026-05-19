import 'package:flutter/widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../feature/databases/domain/entities/database_health.dart';
import '../../../feature/databases/domain/entities/table_stats.dart';
import '../../../feature/monitoring/domain/entities/service_status.dart';

// ── private helpers ───────────────────────────────────────────────────────────

String _formatRelative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  return 'Hace ${diff.inDays} días';
}

String _tableDescription(String name) => switch (name) {
  'metrics' => 'Lecturas SNMP cada 5 min',
  'collector_runs' => 'Ejecuciones del agente Go',
  'service_events' => 'Incidentes registrados',
  'monitored_services' => 'Passbolt · ChkMonitor',
  'users' => 'Admin + 2 visualizadores',
  _ => name,
};

Color _tableColor(String name) => switch (name) {
  'metrics' => AppColors.chartCpu,
  'collector_runs' => AppColors.secondary,
  'service_events' => AppColors.warning,
  'monitored_services' => AppColors.primary,
  'users' => AppColors.primaryBright,
  _ => AppColors.textSecondary,
};

// ── models ────────────────────────────────────────────────────────────────────

class DatabaseHealthModel {
  DatabaseHealthModel({
    required this.status,
    required this.latencyMs,
    required this.storageMb,
    required this.cacheHitPercent,
    required this.activeConnections,
    required this.totalTables,
    required this.totalRows,
    required this.lastWrite,
    required this.tableStats,
  });

  final ServiceStatus status;
  final int latencyMs;
  final int storageMb;
  final double cacheHitPercent;
  final int activeConnections;
  final int totalTables;
  final int totalRows;
  final String lastWrite;
  final List<TableStatModel> tableStats;
}

class TableStatModel {
  TableStatModel({
    required this.name,
    required this.rows,
    required this.description,
    required this.color,
  });

  final String name;
  final int rows;
  final String description;
  final Color color;
}

// ── extensions ────────────────────────────────────────────────────────────────

extension DatabaseHealthModelX on DatabaseHealth {
  DatabaseHealthModel toModel(List<TableStats> stats) => DatabaseHealthModel(
    status: _resolveDatabaseStatus(this),
    latencyMs: latencyMs,
    storageMb: storageMb,
    cacheHitPercent: cacheHitPercent,
    activeConnections: activeConnections,
    totalTables: totalTables,
    totalRows: totalRows,
    lastWrite: lastWriteAt != null ? _formatRelative(lastWriteAt!) : '—',
    tableStats: stats.map((t) => t.toModel()).toList(),
  );
}

ServiceStatus _resolveDatabaseStatus(DatabaseHealth health) {
  final now = DateTime.now();
  final snapshotAge = now.difference(health.collectedAt);

  if (snapshotAge > const Duration(minutes: 10)) {
    return ServiceStatus.offline;
  }

  final lastActivity = health.lastWriteAt;
  if (lastActivity == null) {
    return ServiceStatus.warning;
  }

  final activityAge = now.difference(lastActivity);
  if (activityAge <= const Duration(minutes: 5)) {
    return ServiceStatus.online;
  }
  if (activityAge <= const Duration(minutes: 15)) {
    return ServiceStatus.warning;
  }
  if (activityAge <= const Duration(hours: 1)) {
    return ServiceStatus.degraded;
  }
  return ServiceStatus.offline;
}

extension TableStatModelX on TableStats {
  TableStatModel toModel() => TableStatModel(
    name: tableName,
    rows: liveRows,
    description: _tableDescription(tableName),
    color: _tableColor(tableName),
  );
}
