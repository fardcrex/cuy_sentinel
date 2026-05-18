import '../domain/entities/database_health.dart';
import '../domain/entities/database_instance.dart';
import '../domain/entities/table_stats.dart';
import '../domain/interfaces/i_databases_repository.dart';

// Fase 1: implementar con Supabase REST (pg_stat_database, pg_stat_user_tables)
class SupabaseDatabasesRepository implements IDatabasesRepository {
  @override
  Future<List<DatabaseInstance>> getInstances() =>
      throw UnimplementedError('SupabaseDatabasesRepository.getInstances');

  @override
  Future<DatabaseHealth> getHealth(String instanceId) =>
      throw UnimplementedError('SupabaseDatabasesRepository.getHealth');

  @override
  Stream<DatabaseHealth> watchHealth(String instanceId) => Stream.error(
    UnimplementedError('SupabaseDatabasesRepository.watchHealth'),
  );

  @override
  Future<List<TableStats>> getTableStats(String instanceId) =>
      throw UnimplementedError('SupabaseDatabasesRepository.getTableStats');
}
