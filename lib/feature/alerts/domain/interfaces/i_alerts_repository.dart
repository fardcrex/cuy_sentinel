import '../../../../core/utils/stream_retry.dart';
import '../entities/alert_event.dart';
import '../entities/alert_threshold.dart';

abstract interface class IAlertsRepository {
  Future<List<AlertThreshold>> getThresholds();
  Stream<List<AlertEvent>> watchActiveAlerts({
    void Function(RetryState)? onRetry,
  });
  /// Emits one [AlertEvent] each time a new (unresolved) alert is inserted.
  /// [onSubscribed] se llama cada vez que el canal realtime se suscribe
  /// exitosamente — incluyendo reconexiones. Úsalo para catchup de alertas
  /// perdidas durante la desconexión.
  Stream<AlertEvent> watchAlertInserts({void Function()? onSubscribed});
  Future<List<AlertEvent>> getAlertHistory({int limit = 50});
  /// Devuelve alertas no resueltas disparadas estrictamente después de [since],
  /// ordenadas por [triggered_at] ascendente (más antiguas primero).
  Future<List<AlertEvent>> getAlertsSince(DateTime since);
  Future<void> resolveAlert(String alertId);
}
