import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/databases/application/get_database_health_use_case.dart';
import '../../../feature/databases/domain/interfaces/i_databases_repository.dart';

abstract final class DatabasesModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IDatabasesRepository repo,
  ) => [
    RepositoryProvider<GetDatabaseInstancesUseCase>(
      create: (_) => GetDatabaseInstancesUseCase(repo),
    ),
    RepositoryProvider<GetDatabaseHealthUseCase>(
      create: (_) => GetDatabaseHealthUseCase(repo),
    ),
    RepositoryProvider<WatchDatabaseHealthUseCase>(
      create: (_) => WatchDatabaseHealthUseCase(repo),
    ),
    RepositoryProvider<GetTableStatsUseCase>(
      create: (_) => GetTableStatsUseCase(repo),
    ),
  ];
}
