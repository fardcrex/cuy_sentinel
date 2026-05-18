import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../feature/auth/domain/auth_exception.dart';
import 'bloc/auth_bloc.dart';
import 'widgets/login_form_card.dart';
import 'widgets/login_illustration_panel.dart';
import 'widgets/login_matrix_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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
    if (_hasLoginError && mounted) {
      setState(() => _hasLoginError = false);
    }
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
      builder: (context, state) {
        final isSubmitting = state is AuthLoading;
        final matrixTone =
            _hasLoginError ? _matrixAlertPrimary : AppColors.primary;
        final matrixAccent =
            _hasLoginError ? _matrixAlertAccent : AppColors.primaryBright;
        final bgStart = Color.lerp(
          AppColors.background,
          AppColors.warning,
          _hasLoginError ? _warningBgStart : 0,
        )!;
        final bgEnd = Color.lerp(
          AppColors.panel,
          AppColors.critical,
          _hasLoginError ? _warningBgEnd : 0,
        )!;

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgStart, bgEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _bgController,
                      builder: (_, _) => CustomPaint(
                        painter: LoginMatrixBackgroundPainter(
                          progress: _bgController.value,
                          density: 0.8,
                          toneColor: matrixTone,
                          accentToneColor: matrixAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => context.go(AppRoutes.welcome),
                        child: Image.asset(
                          AppAssets.logoHorizontalPrimary,
                          height: 34,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop =
                          AppBreakpoints.isDesktop(constraints.maxWidth);
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppBreakpoints.horizontalPadding(
                                constraints.maxWidth,
                              ),
                              vertical: 80,
                            ),
                            child: isDesktop
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: LoginIllustrationPanel(
                                          hasError: _hasLoginError,
                                        ),
                                      ),
                                      const SizedBox(width: 56),
                                      Expanded(
                                        flex: 4,
                                        child: LoginFormCard(
                                          formKey: _formKey,
                                          userController: _userController,
                                          passwordController:
                                              _passwordController,
                                          obscurePassword: _obscurePassword,
                                          isSubmitting: isSubmitting,
                                          onTogglePassword: () => setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          }),
                                          onSubmit: () => _submit(context),
                                        ),
                                      ),
                                    ],
                                  )
                                : LoginFormCard(
                                    formKey: _formKey,
                                    userController: _userController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    isSubmitting: isSubmitting,
                                    onTogglePassword: () => setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    }),
                                    onSubmit: () => _submit(context),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}