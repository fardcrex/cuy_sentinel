import '../../../feature/alerts/infrastructure/in_memory_alerts_repository.dart';
import '../../../feature/auth/infrastructure/in_memory_auth_repository.dart';
import '../../../feature/databases/infrastructure/in_memory_databases_repository.dart';
import '../../../feature/metrics/infrastructure/in_memory_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/in_memory_monitoring_repository.dart';
import '../../../feature/users/infrastructure/in_memory_users_repository.dart';
import '../app_dependencies.dart';

// Demo mode: all repositories use in-memory seed data.
// Stream-based repos emit periodic updates to simulate real-time collection.
// No credentials or network required.
AppDependencies buildDemoDependencies() => AppDependencies(
  authRepository: InMemoryAuthRepository(),
  monitoringRepository: InMemoryMonitoringRepository(),
  metricsRepository: InMemoryMetricsRepository(),
  alertsRepository: InMemoryAlertsRepository(),
  usersRepository: InMemoryUsersRepository(),
  databasesRepository: InMemoryDatabasesRepository(),
);
