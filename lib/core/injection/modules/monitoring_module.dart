import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../../feature/monitoring/application/get_services_use_case.dart';
import '../../../feature/monitoring/domain/interfaces/i_monitoring_repository.dart';

abstract final class MonitoringModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IMonitoringRepository repo,
  ) => [
    RepositoryProvider<GetServicesUseCase>(
      create: (_) => GetServicesUseCase(repo),
    ),
    RepositoryProvider<GetServiceEventsUseCase>(
      create: (_) => GetServiceEventsUseCase(repo),
    ),
    RepositoryProvider<WatchActiveEventsUseCase>(
      create: (_) => WatchActiveEventsUseCase(repo),
    ),
    RepositoryProvider<GetCollectorRunsUseCase>(
      create: (_) => GetCollectorRunsUseCase(repo),
    ),
    RepositoryProvider<WatchLastCollectorRunUseCase>(
      create: (_) => WatchLastCollectorRunUseCase(repo),
    ),
  ];
}
