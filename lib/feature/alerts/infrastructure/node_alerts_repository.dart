import '../../../core/utils/stream_retry.dart';
import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

// Fase 2: implementar con Node.js API + Socket.IO
class NodeAlertsRepository implements IAlertsRepository {
  @override
  Future<List<AlertThreshold>> getThresholds() =>
      throw UnimplementedError('NodeAlertsRepository.getThresholds');

  @override
  Future<List<AlertEvent>> getAlertHistory({int limit = 50}) =>
      throw UnimplementedError('NodeAlertsRepository.getAlertHistory');

  @override
  Future<void> resolveAlert(String alertId) =>
      throw UnimplementedError('NodeAlertsRepository.resolveAlert');

  @override
  Stream<List<AlertEvent>> watchActiveAlerts({
    void Function(RetryState)? onRetry,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<AlertEvent>> getAlertsSince(DateTime since) {
    throw UnimplementedError();
  }

  @override
  Stream<AlertEvent> watchAlertInserts({void Function()? onSubscribed}) {
    throw UnimplementedError();
  }
}
