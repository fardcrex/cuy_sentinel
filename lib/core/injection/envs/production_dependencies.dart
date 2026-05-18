import '../app_dependencies.dart';
import '../../../feature/alerts/infrastructure/supabase_alerts_repository.dart';
import '../../../feature/auth/infrastructure/supabase_auth_repository.dart';
import '../../../feature/databases/infrastructure/supabase_databases_repository.dart';
import '../../../feature/metrics/infrastructure/supabase_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/supabase_monitoring_repository.dart';
import '../../../feature/users/infrastructure/supabase_users_repository.dart';

AppDependencies buildProductionDependencies() => AppDependencies(
  authRepository: SupabaseAuthRepository(),
  monitoringRepository: SupabaseMonitoringRepository(),
  metricsRepository: SupabaseMetricsRepository(),
  alertsRepository: SupabaseAlertsRepository(),
  usersRepository: SupabaseUsersRepository(),
  databasesRepository: SupabaseDatabasesRepository(),
);
