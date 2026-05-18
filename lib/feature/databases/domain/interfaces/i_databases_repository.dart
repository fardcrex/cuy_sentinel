import '../entities/database_health.dart';
import '../entities/database_instance.dart';
import '../entities/table_stats.dart';

abstract interface class IDatabasesRepository {
  /// Returns all configured instances (active and disabled).
  Future<List<DatabaseInstance>> getInstances();

  /// Fetches the current health snapshot for one instance.
  /// Runs the SQL queries described in DatabaseHealth field docs.
  Future<DatabaseHealth> getHealth(String instanceId);

  /// Real-time stream — emits a new snapshot after every collector cycle.
  Stream<DatabaseHealth> watchHealth(String instanceId);

  /// Returns per-table statistics for one instance.
  Future<List<TableStats>> getTableStats(String instanceId);
}
