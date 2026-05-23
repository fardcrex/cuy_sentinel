import 'dart:async' show unawaited;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/auth/application/sign_in_use_case.dart';
import '../../../feature/auth/application/sign_out_use_case.dart';
import '../../../feature/auth/application/watch_session_use_case.dart';
import '../../../feature/auth/domain/auth_exception.dart';
import '../../../feature/auth/domain/entities/app_user.dart';
import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/entities/user_access_log.dart'
    show UserAccessAction;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInUseCase signIn,
    required SignOutUseCase signOut,
    required WatchSessionUseCase watchSession,
    required LogAccessUseCase logAccess,
    required TrackPresenceUseCase trackPresence,
    required UntrackPresenceUseCase untrackPresence,
    required AppUser? initialSession,
  }) : _signIn = signIn,
       _signOut = signOut,
       _watchSession = watchSession,
       _logAccess = logAccess,
       _trackPresence = trackPresence,
       _untrackPresence = untrackPresence,
       super(
         initialSession != null
             ? AuthAuthenticated(initialSession)
             : const AuthUnauthenticated(),
       ) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthPresenceResumed>(_onPresenceResumed);
    on<AuthPresencePaused>(_onPresencePaused);

    if (initialSession != null) {
      unawaited(_trackPresence.execute(initialSession.id));
    }
  }

  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;
  final WatchSessionUseCase _watchSession;
  final LogAccessUseCase _logAccess;
  final TrackPresenceUseCase _trackPresence;
  final UntrackPresenceUseCase _untrackPresence;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach(
      _watchSession.execute(),
      onData: (user) {
        if (user != null) {
          unawaited(_trackPresence.execute(user.id));
          return AuthAuthenticated(user);
        } else {
          unawaited(_untrackPresence.execute());
          return const AuthUnauthenticated();
        }
      },
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
      unawaited(
        _logAccess.execute(
          userId: user.id,
          fallbackName: user.email,
          action: UserAccessAction.login,
          loggedIn: true,
        ),
      );
      unawaited(_trackPresence.execute(user.id));
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
    final current = state;
    if (current is AuthAuthenticated) {
      await _untrackPresence.execute();
      await _logAccess.execute(
        userId: current.user.id,
        fallbackName: current.user.email,
        action: UserAccessAction.logout,
        loggedIn: false,
      );
    }
    await _signOut.execute();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onPresenceResumed(
    AuthPresenceResumed event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is AuthAuthenticated) {
      await _trackPresence.execute(current.user.id);
    }
  }

  Future<void> _onPresencePaused(
    AuthPresencePaused event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      await _untrackPresence.execute();
    }
  }
}
