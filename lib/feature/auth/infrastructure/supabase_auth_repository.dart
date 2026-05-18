import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../domain/auth_exception.dart';
import '../domain/entities/app_user.dart';
import '../domain/interfaces/i_auth_repository.dart';

class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository() : _client = supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  @override
  AppUser? currentSession() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(id: user.id, email: user.email ?? '');
  }

  @override
  Stream<AppUser?> watchSession() => _client.auth.onAuthStateChange.map(
        (event) {
          final user = event.session?.user;
          if (user == null) return null;
          return AppUser(id: user.id, email: user.email ?? '');
        },
      );

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) throw const ServerAuthException('Usuario no encontrado');
      return AppUser(id: user.id, email: user.email ?? '');
    } on supabase.AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid')) {
        throw const InvalidCredentialsException();
      }
      throw ServerAuthException(e.message);
    } catch (e) {
      if (e is InvalidCredentialsException || e is ServerAuthException) rethrow;
      throw ServerAuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
