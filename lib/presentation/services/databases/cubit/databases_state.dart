import '../../../../feature/databases/domain/entities/database_health.dart';
import '../../../../feature/databases/domain/entities/table_stats.dart';

sealed class DatabasesState {}

final class DatabasesInitial extends DatabasesState {}

final class DatabasesLoading extends DatabasesState {}

final class DatabasesLoaded extends DatabasesState {
  DatabasesLoaded({required this.health, required this.tableStats});

  final DatabaseHealth health;
  final List<TableStats> tableStats;
}

final class DatabasesError extends DatabasesState {
  DatabasesError(this.message);
  final String message;
}
