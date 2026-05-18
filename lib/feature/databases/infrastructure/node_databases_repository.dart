import '../domain/entities/database_health.dart';
import '../domain/entities/database_instance.dart';
import '../domain/entities/table_stats.dart';
import '../domain/interfaces/i_databases_repository.dart';

// Fase 2: implementar con Node.js API + Socket.IO
class NodeDatabasesRepository implements IDatabasesRepository {
  @override
  Future<List<DatabaseInstance>> getInstances() =>
      throw UnimplementedError('NodeDatabasesRepository.getInstances');

  @override
  Future<DatabaseHealth> getHealth(String instanceId) =>
      throw UnimplementedError('NodeDatabasesRepository.getHealth');

  @override
  Stream<DatabaseHealth> watchHealth(String instanceId) => Stream.error(
    UnimplementedError('NodeDatabasesRepository.watchHealth'),
  );

  @override
  Future<List<TableStats>> getTableStats(String instanceId) =>
      throw UnimplementedError('NodeDatabasesRepository.getTableStats');
}
