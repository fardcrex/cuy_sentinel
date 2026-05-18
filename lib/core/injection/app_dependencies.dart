import '../../feature/auth/domain/interfaces/i_auth_repository.dart';

class AppDependencies {
  const AppDependencies({required this.authRepository});
  final IAuthRepository authRepository;
}
