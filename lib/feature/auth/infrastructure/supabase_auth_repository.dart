import '../domain/entities/app_user.dart';
import '../domain/interfaces/i_auth_repository.dart';

// Phase 1: implementar con Supabase Auth
class SupabaseAuthRepository implements IAuthRepository {
  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError('SupabaseAuthRepository.signIn');

  @override
  Future<void> signOut() =>
      throw UnimplementedError('SupabaseAuthRepository.signOut');

  @override
  Future<AppUser?> getCurrentUser() =>
      throw UnimplementedError('SupabaseAuthRepository.getCurrentUser');
}
