import 'dart:async';

import '../domain/auth_exception.dart';
import '../domain/entities/app_user.dart';
import '../domain/interfaces/i_auth_repository.dart';

class InMemoryAuthRepository implements IAuthRepository {
  static const _email = 'admin@cuysentinel.local';
  static const _password = 'CuySentinel123';

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  AppUser? currentSession() => _current;

  @override
  Stream<AppUser?> watchSession() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (email.trim() != _email || password != _password) {
      throw const InvalidCredentialsException();
    }
    final user = AppUser(id: 'dev-001', email: email.trim());
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
