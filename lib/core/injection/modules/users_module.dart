import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/interfaces/i_users_repository.dart';

abstract final class UsersModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IUsersRepository repo,
  ) => [
    RepositoryProvider<WatchPanelUsersUseCase>(
      create: (_) => WatchPanelUsersUseCase(repo),
    ),
    RepositoryProvider<GetPanelUsersUseCase>(
      create: (_) => GetPanelUsersUseCase(repo),
    ),
    RepositoryProvider<GetAccessLogsUseCase>(
      create: (_) => GetAccessLogsUseCase(repo),
    ),
  ];
}
