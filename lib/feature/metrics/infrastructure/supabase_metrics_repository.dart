import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/utils/stream_retry.dart';
import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

class SupabaseMetricsRepository implements IMetricsRepository {
  SupabaseMetricsRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  @override
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  }) => retryStream(
        () => _client
            .from('metrics')
            .stream(primaryKey: ['id'])
            .eq('service_id', serviceId)
            .order('collected_at', ascending: false)
            .limit(limit)
            .map((rows) => rows.map(Metric.fromJson).toList()),
      );

  @override
  Future<List<Metric>> getByRange({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client
        .from('metrics')
        .select()
        .eq('service_id', serviceId)
        .gte('collected_at', from.toUtc().toIso8601String())
        .lte('collected_at', to.toUtc().toIso8601String())
        .order('collected_at');
    return rows.map(Metric.fromJson).toList();
  }
}
