import '../entities/app_user.dart';

abstract interface class IAuthRepository {
  AppUser? currentSession();
  Stream<AppUser?> watchSession();
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
}
