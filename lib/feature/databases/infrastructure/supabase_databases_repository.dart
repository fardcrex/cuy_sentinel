import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/utils/stream_retry.dart';
import '../domain/entities/database_health.dart';
import '../domain/entities/database_instance.dart';
import '../domain/entities/table_stats.dart';
import '../domain/interfaces/i_databases_repository.dart';

class SupabaseDatabasesRepository implements IDatabasesRepository {
  SupabaseDatabasesRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  // Fase 1 only exposes the Supabase instance.
  @override
  Future<List<DatabaseInstance>> getInstances() async =>
      const [DatabaseInstance.passboltSupabase];

  @override
  Future<DatabaseHealth> getHealth(String instanceId) async {
    final result = await _client.rpc('get_database_health');
    return DatabaseHealth.fromJson(Map<String, dynamic>.from(result as Map));
  }

  // Polls every 30 s — no Realtime table to watch for pg_stat views.
  @override
  Stream<DatabaseHealth> watchHealth(
    String instanceId, {
    void Function(RetryState)? onRetry,
  }) => retryStream(
    () => Stream.periodic(const Duration(seconds: 30), (_) => getHealth(instanceId))
        .asyncMap((future) => future),
    onRetry: onRetry,
  );

  @override
  Future<List<TableStats>> getTableStats(String instanceId) async {
    final result = await _client.rpc('get_table_stats');
    final list = result as List<dynamic>;
    return list
        .map((e) => TableStats.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
