import '../../../../feature/databases/domain/entities/database_health.dart';
import '../../../../feature/databases/domain/entities/table_stats.dart';

sealed class DatabasesState {}

final class DatabasesInitial extends DatabasesState {}

final class DatabasesLoading extends DatabasesState {}

final class DatabasesLoaded extends DatabasesState {
  DatabasesLoaded({
    required this.health,
    required this.tableStats,
    this.isReconnecting = false,
    this.reconnectingInSeconds,
  });

  final DatabaseHealth health;
  final List<TableStats> tableStats;
  final bool isReconnecting;
  final int? reconnectingInSeconds;
}

final class DatabasesError extends DatabasesState {
  DatabasesError(this.message);
  final String message;
}
