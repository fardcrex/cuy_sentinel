import '../domain/entities/monitored_service.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class GetServicesUseCase {
  const GetServicesUseCase(this._repository);

  final IMonitoringRepository _repository;

  Future<List<MonitoredService>> execute() => _repository.getServices();
}
