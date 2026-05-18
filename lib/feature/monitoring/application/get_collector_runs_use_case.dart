import '../domain/entities/collector_run.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class GetCollectorRunsUseCase {
  const GetCollectorRunsUseCase(this._repository);

  final IMonitoringRepository _repository;

  Future<List<CollectorRun>> execute({int limit = 50}) =>
      _repository.getCollectorRuns(limit: limit);
}

class WatchLastCollectorRunUseCase {
  const WatchLastCollectorRunUseCase(this._repository);

  final IMonitoringRepository _repository;

  Stream<CollectorRun?> execute() => _repository.watchLastCollectorRun();
}
