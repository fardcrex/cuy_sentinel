import '../../../core/utils/stream_retry.dart';
import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

class WatchActiveAlertsUseCase {
  const WatchActiveAlertsUseCase(this._repository);

  final IAlertsRepository _repository;

  Stream<List<AlertEvent>> execute({
    void Function(RetryState)? onRetry,
  }) => _repository.watchActiveAlerts(onRetry: onRetry);
}

class WatchAlertInsertsUseCase {
  const WatchAlertInsertsUseCase(this._repository);

  final IAlertsRepository _repository;

  Stream<AlertEvent> execute({void Function()? onSubscribed}) =>
      _repository.watchAlertInserts(onSubscribed: onSubscribed);
}

class GetAlertsSinceUseCase {
  const GetAlertsSinceUseCase(this._repository);

  final IAlertsRepository _repository;

  Future<List<AlertEvent>> execute(DateTime since) =>
      _repository.getAlertsSince(since);
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

class ResolveAlertUseCase {
  const ResolveAlertUseCase(this._repository);

  final IAlertsRepository _repository;

  Future<void> execute(String alertId) => _repository.resolveAlert(alertId);
}
