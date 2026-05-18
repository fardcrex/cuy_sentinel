import '../domain/entities/alert_event.dart';
import '../domain/entities/alert_threshold.dart';
import '../domain/interfaces/i_alerts_repository.dart';

// Fase 1: implementar con Supabase Realtime channel (postgres_changes INSERT)
class SupabaseAlertsRepository implements IAlertsRepository {
  @override
  Stream<List<AlertEvent>> watchActiveAlerts() => Stream.error(
    UnimplementedError('SupabaseAlertsRepository.watchActiveAlerts'),
  );

  @override
  Future<List<AlertThreshold>> getThresholds() =>
      throw UnimplementedError('SupabaseAlertsRepository.getThresholds');

  @override
  Future<List<AlertEvent>> getAlertHistory({int limit = 50}) =>
      throw UnimplementedError('SupabaseAlertsRepository.getAlertHistory');

  @override
  Future<void> resolveAlert(String alertId) =>
      throw UnimplementedError('SupabaseAlertsRepository.resolveAlert');
}
