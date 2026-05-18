import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

class WatchActiveAlertsUseCase {
  const WatchActiveAlertsUseCase(this._repository);

  final IAlertsRepository _repository;

  Stream<List<AlertEvent>> execute() => _repository.watchActiveAlerts();
}

class GetAlertHistoryUseCase {
  const GetAlertHistoryUseCase(this._repository);

  final IAlertsRepository _repository;

  Future<List<AlertEvent>> execute({int limit = 50}) =>
      _repository.getAlertHistory(limit: limit);
}

class GetAlertThresholdsUseCase {
  const GetAlertThresholdsUseCase(this._repository);

  final IAlertsRepository _repository;

  Future<List<AlertThreshold>> execute() => _repository.getThresholds();
}
