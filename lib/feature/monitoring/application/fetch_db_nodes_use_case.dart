import '../domain/entities/db_node.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class FetchDbNodesUseCase {
  const FetchDbNodesUseCase(this._repo);
  final IMonitoringRepository _repo;

  Future<List<DbNode>> execute() => _repo.fetchDbNodes();
}
