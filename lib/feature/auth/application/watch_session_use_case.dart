import '../domain/entities/app_user.dart';
import '../domain/interfaces/i_auth_repository.dart';

class WatchSessionUseCase {
  const WatchSessionUseCase(this._repository);
  final IAuthRepository _repository;

  Stream<AppUser?> execute() => _repository.watchSession();
}
