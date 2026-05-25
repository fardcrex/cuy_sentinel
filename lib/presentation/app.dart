import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/injection/app_dependencies.dart';
import '../core/injection/modules/alerts_module.dart';
import '../core/injection/modules/databases_module.dart';
import '../core/injection/modules/metrics_module.dart';
import '../core/injection/modules/monitoring_module.dart';
import '../core/injection/modules/users_module.dart';
import '../core/navigation/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/alert_notification_dialog.dart';
import '../core/widgets/alert_toast_stack.dart';
import '../feature/alerts/application/get_alerts_use_case.dart';
import '../feature/auth/application/sign_in_use_case.dart';
import '../feature/auth/application/sign_out_use_case.dart';
import '../feature/auth/application/watch_session_use_case.dart';
import '../feature/users/application/get_users_use_case.dart';
import 'alerts/cubit/alert_notifier_cubit.dart';
import 'alerts/cubit/alert_notifier_state.dart';
import 'auth/bloc/auth_bloc.dart';

class CuySentinelApp extends StatefulWidget {
  const CuySentinelApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<CuySentinelApp> createState() => _CuySentinelAppState();
}

class _CuySentinelAppState extends State<CuySentinelApp>
    with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  bool _alertDialogOpen = false;

  @override
  void initState() {
    super.initState();
    final authRepo = widget.dependencies.authRepository;
    final usersRepo = widget.dependencies.usersRepository;
    _authBloc = AuthBloc(
      signIn: SignInUseCase(authRepo),
      signOut: SignOutUseCase(authRepo),
      watchSession: WatchSessionUseCase(authRepo),
      logAccess: LogAccessUseCase(
        usersRepo,
        widget.dependencies.deviceInfoService,
      ),
      trackPresence: TrackPresenceUseCase(
        usersRepo,
        widget.dependencies.deviceInfoService,
      ),
      untrackPresence: UntrackPresenceUseCase(usersRepo),
      initialSession: authRepo.currentSession(),
    )..add(const AuthStarted());
    _router = createAppRouter(_authBloc);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.dependencies.onReconnect?.call();
      _authBloc.add(const AuthPresenceResumed());
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _authBloc.add(
        _usesBackgroundPresence
            ? const AuthPresenceAway()
            : const AuthPresencePaused(),
      );
    }
  }

  bool get _usesBackgroundPresence =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.dependencies;
    return MultiRepositoryProvider(
      providers: [
        ...MonitoringModule.repositoryProviders(deps.monitoringRepository),
        ...MetricsModule.repositoryProviders(deps.metricsRepository),
        ...AlertsModule.repositoryProviders(deps.alertsRepository),
        ...UsersModule.repositoryProviders(
          deps.usersRepository,
          deps.deviceInfoService,
        ),
        ...DatabasesModule.repositoryProviders(deps.databasesRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider<AlertNotifierCubit>(
            lazy: false,
            create: (ctx) {
              final cubit = AlertNotifierCubit(
                watchAlertInserts: ctx.read<WatchAlertInsertsUseCase>(),
                getAlertsSince: ctx.read<GetAlertsSinceUseCase>(),
              );
              if (ctx.read<AuthBloc>().state is AuthAuthenticated) {
                cubit.start();
              }
              return cubit;
            },
          ),
        ],
        child: MaterialApp.router(
          title: 'Cuy Sentinel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          routerConfig: _router,
          builder: (ctx, child) => MultiBlocListener(
            listeners: [
              BlocListener<AlertNotifierCubit, AlertNotifierState>(
                listener: (ctx, state) {
                  if (state is! AlertNotifierNewAlert) return;
                  final navCtx = appNavigatorKey.currentContext;
                  if (navCtx == null) return;
                  if (!_alertDialogOpen) {
                    _alertDialogOpen = true;
                    final notifier = ctx.read<AlertNotifierCubit>();
                    showAlertNotificationDialog(
                      navCtx,
                      state.alert,
                      eventListenable: notifier.currentAlert,
                    ).whenComplete(() {
                      _alertDialogOpen = false;
                    });
                  }
                  final overlay = appNavigatorKey.currentState?.overlay;
                  if (overlay != null) {
                    AlertToastStack.add(overlay, state.alert);
                  }
                },
              ),
              BlocListener<AuthBloc, AuthState>(
                listener: (ctx, state) {
                  final notifier = ctx.read<AlertNotifierCubit>();
                  if (state is AuthAuthenticated) {
                    notifier.start();
                  } else if (state is AuthUnauthenticated) {
                    notifier.stop();
                  }
                },
              ),
            ],
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
