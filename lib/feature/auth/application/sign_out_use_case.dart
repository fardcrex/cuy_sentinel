import '../domain/interfaces/i_auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final IAuthRepository _repository;

  Future<void> execute() => _repository.signOut();
}
