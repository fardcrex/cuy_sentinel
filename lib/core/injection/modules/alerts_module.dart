import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/interfaces/i_alerts_repository.dart';

abstract final class AlertsModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IAlertsRepository repo,
  ) => [
    RepositoryProvider<WatchActiveAlertsUseCase>(
      create: (_) => WatchActiveAlertsUseCase(repo),
    ),
    RepositoryProvider<WatchAlertInsertsUseCase>(
      create: (_) => WatchAlertInsertsUseCase(repo),
    ),
    RepositoryProvider<GetAlertHistoryUseCase>(
      create: (_) => GetAlertHistoryUseCase(repo),
    ),
    RepositoryProvider<GetAlertThresholdsUseCase>(
      create: (_) => GetAlertThresholdsUseCase(repo),
    ),
    RepositoryProvider<ResolveAlertUseCase>(
      create: (_) => ResolveAlertUseCase(repo),
    ),
    RepositoryProvider<GetAlertsSinceUseCase>(
      create: (_) => GetAlertsSinceUseCase(repo),
    ),
  ];
}
