import '../../../core/services/device_info_service.dart';
import '../../../feature/alerts/infrastructure/node_alerts_repository.dart';
import '../../../feature/auth/infrastructure/node_auth_repository.dart';
import '../../../feature/databases/infrastructure/node_databases_repository.dart';
import '../../../feature/metrics/infrastructure/node_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/node_monitoring_repository.dart';
import '../../../feature/users/infrastructure/node_users_repository.dart';
import '../app_dependencies.dart';

// Fase 2: Node.js API + Socket.IO.
// Requires --dart-define-from-file=envs/sentinel.phase2.json
AppDependencies buildPhase2Dependencies() => AppDependencies(
  authRepository: NodeAuthRepository(),
  monitoringRepository: NodeMonitoringRepository(),
  metricsRepository: NodeMetricsRepository(),
  alertsRepository: NodeAlertsRepository(),
  usersRepository: NodeUsersRepository(),
  databasesRepository: NodeDatabasesRepository(),
  deviceInfoService: DeviceInfoService(),
);
