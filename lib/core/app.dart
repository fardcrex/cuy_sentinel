import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../feature/auth/application/sign_in_use_case.dart';
import '../feature/auth/application/sign_out_use_case.dart';
import '../feature/auth/application/watch_session_use_case.dart';
import '../presentation/auth/bloc/auth_bloc.dart';
import 'injection/app_dependencies.dart';
import 'injection/modules/alerts_module.dart';
import 'injection/modules/databases_module.dart';
import 'injection/modules/metrics_module.dart';
import 'injection/modules/monitoring_module.dart';
import 'injection/modules/users_module.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

class CuySentinelApp extends StatefulWidget {
  const CuySentinelApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<CuySentinelApp> createState() => _CuySentinelAppState();
}

class _CuySentinelAppState extends State<CuySentinelApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final repo = widget.dependencies.authRepository;
    _authBloc = AuthBloc(
      signIn: SignInUseCase(repo),
      signOut: SignOutUseCase(repo),
      watchSession: WatchSessionUseCase(repo),
      initialSession: repo.currentSession(),
    )..add(const AuthStarted());
    _router = createAppRouter(_authBloc);
  }

  @override
  void dispose() {
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
        ...UsersModule.repositoryProviders(deps.usersRepository),
        ...DatabasesModule.repositoryProviders(deps.databasesRepository),
      ],
      child: BlocProvider.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'Cuy Sentinel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
