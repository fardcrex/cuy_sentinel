import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/auth/application/sign_in_use_case.dart';
import '../../../feature/auth/application/sign_out_use_case.dart';
import '../../../feature/auth/application/watch_session_use_case.dart';
import '../../../feature/auth/domain/interfaces/i_auth_repository.dart';

abstract final class AuthModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IAuthRepository repo,
  ) =>
      [
        RepositoryProvider<SignInUseCase>(
          create: (_) => SignInUseCase(repo),
        ),
        RepositoryProvider<SignOutUseCase>(
          create: (_) => SignOutUseCase(repo),
        ),
        RepositoryProvider<WatchSessionUseCase>(
          create: (_) => WatchSessionUseCase(repo),
        ),
      ];
}
