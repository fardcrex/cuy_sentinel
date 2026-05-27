import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/utils/stream_retry.dart';

import '../domain/entities/collector_run.dart';
import '../domain/entities/db_node.dart';
import '../domain/entities/monitored_service.dart';
import '../domain/entities/service_event.dart';
import '../domain/interfaces/i_monitoring_repository.dart';

class SupabaseMonitoringRepository implements IMonitoringRepository {
  SupabaseMonitoringRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  @override
  Future<List<MonitoredService>> getServices() async {
    final rows = await _client
        .from('monitored_services')
        .select()
        .eq('enabled', true)
        .order('service_name');
    return rows.map(MonitoredService.fromJson).toList();
  }

  @override
  Future<MonitoredService?> getServiceById(String id) async {
    final rows = await _client
        .from('monitored_services')
        .select()
        .eq('id', id)
        .limit(1);
    if (rows.isEmpty) return null;
    return MonitoredService.fromJson(rows.first);
  }

  @override
  Future<List<ServiceEvent>> getServiceEvents({
    required String serviceId,
    int limit = 20,
  }) async {
    final rows = await _client
        .from('service_events')
        .select()
        .eq('service_id', serviceId)
        .order('started_at', ascending: false)
        .limit(limit);
    return rows.map(ServiceEvent.fromJson).toList();
  }

  @override
  Future<List<ServiceEvent>> getRecentServiceEvents({int limit = 30}) async {
    final rows = await _client
        .from('service_events')
        .select('*, monitored_services(service_name)')
        .order('started_at', ascending: false)
        .limit(limit);
    return rows.map(ServiceEvent.fromJson).toList();
  }

  @override
  Stream<List<ServiceEvent>> watchActiveEvents({
    void Function(RetryState)? onRetry,
  }) => retryStream(
        () => _client
            .from('service_events')
            .stream(primaryKey: ['id'])
            .order('started_at', ascending: false)
            .map(
              (rows) => rows
                  .map(ServiceEvent.fromJson)
                  .where((e) => !e.resolved)
                  .toList(),
            ),
        onRetry: onRetry,
      );

  @override
  Future<List<CollectorRun>> getCollectorRuns({int limit = 50}) async {
    final rows = await _client
        .from('collector_runs')
        .select()
        .order('started_at', ascending: false)
        .limit(limit);
    return rows.map(CollectorRun.fromJson).toList();
  }

  @override
  Stream<CollectorRun?> watchLastCollectorRun({
    void Function(RetryState)? onRetry,
  }) => retryStream(
        () => _client
            .from('collector_runs')
            .stream(primaryKey: ['id'])
            .order('started_at', ascending: false)
            .limit(1)
            .map((rows) => rows.isEmpty ? null : CollectorRun.fromJson(rows.first)),
        onRetry: onRetry,
      );

  @override
  Future<List<DbNode>> fetchDbNodes() async => [];
}
