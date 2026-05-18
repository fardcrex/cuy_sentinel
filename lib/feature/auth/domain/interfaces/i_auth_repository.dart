import '../entities/app_user.dart';

abstract interface class IAuthRepository {
  Future<AppUser?> signIn({required String email, required String password});
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
}
