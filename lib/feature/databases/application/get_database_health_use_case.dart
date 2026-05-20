import '../../../core/utils/stream_retry.dart';
import '../domain/entities/database_health.dart';
import '../domain/entities/database_instance.dart';
import '../domain/entities/table_stats.dart';
import '../domain/interfaces/i_databases_repository.dart';

class GetDatabaseInstancesUseCase {
  const GetDatabaseInstancesUseCase(this._repository);

  final IDatabasesRepository _repository;

  Future<List<DatabaseInstance>> execute() => _repository.getInstances();
}

class GetDatabaseHealthUseCase {
  const GetDatabaseHealthUseCase(this._repository);

  final IDatabasesRepository _repository;

  Future<DatabaseHealth> execute(String instanceId) =>
      _repository.getHealth(instanceId);
}

class WatchDatabaseHealthUseCase {
  const WatchDatabaseHealthUseCase(this._repository);

  final IDatabasesRepository _repository;

  Stream<DatabaseHealth> execute(
    String instanceId, {
    void Function(RetryState)? onRetry,
  }) => _repository.watchHealth(instanceId, onRetry: onRetry);
}

class GetTableStatsUseCase {
  const GetTableStatsUseCase(this._repository);

  final IDatabasesRepository _repository;

  Future<List<TableStats>> execute(String instanceId) =>
      _repository.getTableStats(instanceId);
}
