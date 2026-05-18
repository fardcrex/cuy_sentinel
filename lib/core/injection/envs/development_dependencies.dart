import '../app_dependencies.dart';
import '../../../feature/alerts/infrastructure/supabase_alerts_repository.dart';
import '../../../feature/auth/infrastructure/in_memory_auth_repository.dart';
import '../../../feature/databases/infrastructure/supabase_databases_repository.dart';
import '../../../feature/metrics/infrastructure/supabase_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/supabase_monitoring_repository.dart';
import '../../../feature/users/infrastructure/supabase_users_repository.dart';

// Dev mode: auth uses an in-memory stub (no credentials needed).
// All other repos use the same Supabase stubs as production — they throw
// UnimplementedError when called, but the UI uses hardcoded seed data
// until BLoCs are wired up.
AppDependencies buildDevelopmentDependencies() => AppDependencies(
  authRepository: InMemoryAuthRepository(),
  monitoringRepository: SupabaseMonitoringRepository(),
  metricsRepository: SupabaseMetricsRepository(),
  alertsRepository: SupabaseAlertsRepository(),
  usersRepository: SupabaseUsersRepository(),
  databasesRepository: SupabaseDatabasesRepository(),
);
