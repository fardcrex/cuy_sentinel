import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/device_info_service.dart';
import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/interfaces/i_users_repository.dart';

abstract final class UsersModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IUsersRepository repo,
    IDeviceInfoService deviceInfo,
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
    RepositoryProvider<LogAccessUseCase>(
      create: (_) => LogAccessUseCase(repo, deviceInfo),
    ),
    RepositoryProvider<WatchAccessLogsUseCase>(
      create: (_) => WatchAccessLogsUseCase(repo),
    ),
    RepositoryProvider<WatchPresenceUseCase>(
      create: (_) => WatchPresenceUseCase(repo),
    ),
    RepositoryProvider<TrackPresenceUseCase>(
      create: (_) => TrackPresenceUseCase(repo, deviceInfo),
    ),
    RepositoryProvider<UntrackPresenceUseCase>(
      create: (_) => UntrackPresenceUseCase(repo),
    ),
  ];
}
