part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthPresenceResumed extends AuthEvent {
  const AuthPresenceResumed();
}

class AuthPresencePaused extends AuthEvent {
  const AuthPresencePaused();
}
