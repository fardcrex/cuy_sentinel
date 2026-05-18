import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/auth/application/sign_in_use_case.dart';
import '../../../feature/auth/application/sign_out_use_case.dart';
import '../../../feature/auth/application/watch_session_use_case.dart';
import '../../../feature/auth/domain/auth_exception.dart';
import '../../../feature/auth/domain/entities/app_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInUseCase signIn,
    required SignOutUseCase signOut,
    required WatchSessionUseCase watchSession,
    required AppUser? initialSession,
  })  : _signIn = signIn,
        _signOut = signOut,
        _watchSession = watchSession,
        super(
          initialSession != null
              ? AuthAuthenticated(initialSession)
              : const AuthUnauthenticated(),
        ) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;
  final WatchSessionUseCase _watchSession;

  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach(
      _watchSession.execute(),
      onData: (user) => user != null
          ? AuthAuthenticated(user)
          : const AuthUnauthenticated(),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signIn.execute(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e));
    } catch (e) {
      emit(AuthError(ServerAuthException(e.toString())));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut.execute();
    emit(const AuthUnauthenticated());
  }
}
