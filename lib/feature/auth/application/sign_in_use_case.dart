import '../domain/entities/app_user.dart';
import '../domain/interfaces/i_auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);
  final IAuthRepository _repository;

  Future<AppUser> execute({required String email, required String password}) =>
      _repository.signIn(email: email, password: password);
}
