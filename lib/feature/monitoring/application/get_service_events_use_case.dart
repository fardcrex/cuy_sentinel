import '../domain/entities/service_event.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class GetServiceEventsUseCase {
  const GetServiceEventsUseCase(this._repository);

  final IMonitoringRepository _repository;

  Future<List<ServiceEvent>> execute({
    required String serviceId,
    int limit = 20,
  }) => _repository.getServiceEvents(serviceId: serviceId, limit: limit);
}

class WatchActiveEventsUseCase {
  const WatchActiveEventsUseCase(this._repository);

  final IMonitoringRepository _repository;

  Stream<List<ServiceEvent>> execute() => _repository.watchActiveEvents();
}
