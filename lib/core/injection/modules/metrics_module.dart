import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/metrics/application/get_latest_metrics_use_case.dart';
import '../../../feature/metrics/application/get_metrics_history_use_case.dart';
import '../../../feature/metrics/domain/interfaces/i_metrics_repository.dart';

abstract final class MetricsModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IMetricsRepository repo,
  ) => [
    RepositoryProvider<WatchLatestMetricsUseCase>(
      create: (_) => WatchLatestMetricsUseCase(repo),
    ),
    RepositoryProvider<GetMetricsHistoryUseCase>(
      create: (_) => GetMetricsHistoryUseCase(repo),
    ),
  ];
}
