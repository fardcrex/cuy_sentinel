import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../feature/auth/domain/auth_exception.dart';
import 'bloc/auth_bloc.dart';
import 'views/login_content_view.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  static const _matrixAlertPrimary = Color(0xFFFF5A36);
  static const _matrixAlertAccent = Color(0xFFFF2D2D);
  static const _warningBgStart = 0.01;
  static const _warningBgEnd = 0.08;

  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _bgController;

  bool _obscurePassword = true;
  bool _hasLoginError = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _userController.addListener(_clearError);
    _passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (_hasLoginError && mounted) setState(() => _hasLoginError = false);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _userController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.dashboard);
        } else if (state is AuthError) {
          setState(() => _hasLoginError = true);
          final msg = switch (state.exception) {
            InvalidCredentialsException() => 'Credenciales incorrectas.',
            ServerAuthException(:final message) =>
              'Error del servidor: $message',
          };
          AppToast.error(context, msg);
        }
      },
      builder: (context, state) => LoginContentView(
        bgController: _bgController,
        matrixTone:
            _hasLoginError ? _matrixAlertPrimary : AppColors.primary,
        matrixAccent:
            _hasLoginError ? _matrixAlertAccent : AppColors.primaryBright,
        bgStart: Color.lerp(
          AppColors.background,
          AppColors.warning,
          _hasLoginError ? _warningBgStart : 0,
        )!,
        bgEnd: Color.lerp(
          AppColors.panel,
          AppColors.critical,
          _hasLoginError ? _warningBgEnd : 0,
        )!,
        formKey: _formKey,
        userController: _userController,
        passwordController: _passwordController,
        obscurePassword: _obscurePassword,
        isSubmitting: state is AuthLoading,
        hasError: _hasLoginError,
        onTogglePassword: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        onSubmit: () => _submit(context),
      ),
    );
  }
}
