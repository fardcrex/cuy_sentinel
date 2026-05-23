import '../../core/services/device_info_service.dart';
import '../../feature/alerts/domain/interfaces/i_alerts_repository.dart';
import '../../feature/auth/domain/interfaces/i_auth_repository.dart';
import '../../feature/databases/domain/interfaces/i_databases_repository.dart';
import '../../feature/metrics/domain/interfaces/i_metrics_repository.dart';
import '../../feature/monitoring/domain/interfaces/i_monitoring_repository.dart';
import '../../feature/users/domain/interfaces/i_users_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.monitoringRepository,
    required this.metricsRepository,
    required this.alertsRepository,
    required this.usersRepository,
    required this.databasesRepository,
    required this.deviceInfoService,
    this.onReconnect,
  });

  final IAuthRepository authRepository;
  final IMonitoringRepository monitoringRepository;
  final IMetricsRepository metricsRepository;
  final IAlertsRepository alertsRepository;
  final IUsersRepository usersRepository;
  final IDatabasesRepository databasesRepository;
  final IDeviceInfoService deviceInfoService;
  final void Function()? onReconnect;
}
