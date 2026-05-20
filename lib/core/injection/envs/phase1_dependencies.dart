import 'package:cuy_sentinel/feature/metrics/infrastructure/in_memory_metrics_repository.dart';
import 'package:cuy_sentinel/feature/monitoring/infrastructure/in_memory_monitoring_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../feature/alerts/infrastructure/supabase_alerts_repository.dart';
import '../../../feature/auth/infrastructure/supabase_auth_repository.dart';
import '../../../feature/databases/infrastructure/supabase_databases_repository.dart';
import '../../../feature/metrics/infrastructure/supabase_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/supabase_monitoring_repository.dart';
import '../../../feature/users/infrastructure/supabase_users_repository.dart';
import '../app_dependencies.dart';

// Fase 1: Supabase REST + Realtime.
// Requires --dart-define-from-file=envs/sentinel.phase1.json
// ignore: invalid_use_of_internal_member
void _reconnectSupabase() => Supabase.instance.client.realtime.connect();

AppDependencies buildPhase1Dependencies() => AppDependencies(
  authRepository: SupabaseAuthRepository(),
  monitoringRepository: SupabaseMonitoringRepository(),
  metricsRepository: SupabaseMetricsRepository(),
  alertsRepository: SupabaseAlertsRepository(),
  usersRepository: SupabaseUsersRepository(),
  databasesRepository: SupabaseDatabasesRepository(),
  onReconnect: _reconnectSupabase,
);

AppDependencies buildPhase1DependenciesMix() => AppDependencies(
  authRepository: SupabaseAuthRepository(),
  monitoringRepository: InMemoryMonitoringRepository(),
  metricsRepository: InMemoryMetricsRepository(),
  databasesRepository: SupabaseDatabasesRepository(),
  alertsRepository: SupabaseAlertsRepository(),
  usersRepository: SupabaseUsersRepository(),
  onReconnect: _reconnectSupabase,
);
