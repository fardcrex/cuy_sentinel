import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../feature/auth/domain/auth_exception.dart';
import '../auth/bloc/auth_bloc.dart';
import '../widgets/app_card.dart';

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
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _userController.text,
          password: _passwordController.text,
        ));
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
                        painter: _MatrixBackgroundPainter(
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
                                        child: _IllustrationPanel(
                                          hasError: _hasLoginError,
                                        ),
                                      ),
                                      const SizedBox(width: 56),
                                      Expanded(
                                        flex: 4,
                                        child: _LoginForm(
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
                                : _LoginForm(
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

// ─── Illustration panel (desktop left side) ──────────────────────────────────

class _IllustrationPanel extends StatelessWidget {
  const _IllustrationPanel({required this.hasError});

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            ),
            child: Image.asset(
              hasError
                  ? AppAssets.illustrationIntrusoDetected
                  : AppAssets.illustrationLoginGuard,
              key: ValueKey(hasError),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            hasError
                ? 'Acceso denegado.\nVerifica tus credenciales.'
                : 'Monitoreo de infraestructura\ndocker en tiempo real.',
            key: ValueKey(hasError),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: hasError ? AppColors.danger : AppColors.primaryWhiteMint,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Passbolt · ChkMonitor · SNMP v2c/v3',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Login form panel ─────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AppCard(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Iniciar sesión',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Panel de monitoreo Cuy Sentinel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: userController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 28),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    gradient: isSubmitting
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryBright],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor:
                          isSubmitting ? AppColors.primary : Colors.transparent,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.primary,
                      disabledForegroundColor: AppColors.background,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: AppColors.primaryBright.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    onPressed: isSubmitting ? null : onSubmit,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.background,
                              ),
                            ),
                          )
                        : const Icon(Icons.login_rounded, size: 20),
                    label: Text(
                      isSubmitting ? 'Validando...' : 'Entrar al panel',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.background,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Matrix background painter (private copy for login) ──────────────────────

const _glyphs = [
  '0', '1', '0', '1', '0', '1', // binary weighted
  '/', r'\', '|', '+', '*', '#',
  '!', '?', '~', ':', '=', '^',
  'A', 'F', 'E', '3', '7', 'B',
];

class _MatrixBackgroundPainter extends CustomPainter {
  _MatrixBackgroundPainter({
    required this.progress,
    required this.density,
    required this.toneColor,
    required this.accentToneColor,
  });

  final double progress;
  final double density;
  final Color toneColor;
  final Color accentToneColor;

  double _noise(int seed) {
    final value = math.sin(seed * 12.9898) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final densityFactor = density.clamp(0.15, 1.0);
    final spacing = 145 - (densityFactor * 50);
    final columnCount = math.max(8, (size.width / spacing).floor());
    const baseStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );
    final isAlert = toneColor.r > toneColor.g;

    for (var index = 0; index < columnCount; index++) {
      final seed = index + 1;
      final baseX = (index + 0.5) * size.width / columnCount;
      final drift =
          math.sin((progress * math.pi * 2) + index * 0.7) * 8;
      final x = baseX + drift;
      // Each column falls at its own speed (0.75x–1.9x) with its own phase.
      final speed = 0.75 + _noise(seed * 17) * 1.15;
      final phase = _noise(seed * 31);
      final travel = (progress * speed + phase) % 1.0;
      final streamLength = 10 + (_noise(seed * 53) * 9).floor(); // 10–19 chars
      final headY = travel * (size.height + 240) - 240;

      for (var segment = 0; segment < streamLength; segment++) {
        final y = headY - (segment * 24);
        if (y < -20 || y > size.height + 20) continue;

        final tailFade = math.pow(
          1.0 - segment / streamLength,
          1.6,
        ).toDouble();
        // Each segment flips at its own rate (4x–24x per cycle) — no sync.
        final segFlipSpeed = 4.0 + _noise((seed * 83) + segment * 19) * 20.0;
        final segTick = (progress * segFlipSpeed).floor();
        final charIdx =
            (_noise((seed * 97) + segment * 11 + segTick * 7) * _glyphs.length)
                .floor()
                .clamp(0, _glyphs.length - 1);
        final glyph = _glyphs[charIdx];
        final blendFactor =
            ((segment / streamLength) * 0.5) +
            (_noise((seed * 59) + segment) * 0.3);

        final Color glyphColor;
        final double opacity;

        if (isAlert) {
          // Head chars flash toward white; tail fades to pure alert red.
          final headFraction = (1.0 - segment / streamLength).clamp(0.0, 1.0);
          glyphColor = Color.lerp(
            toneColor,                       // red at tail
            const Color(0xFFFFE0E0),         // warm white at head
            math.pow(headFraction, 2.2).toDouble(),
          )!;
          opacity = (math.pow(headFraction, 1.4) * 0.92 + 0.06)
              .toDouble()
              .clamp(0.06, 0.92);
        } else {
          glyphColor = Color.lerp(
            toneColor,
            accentToneColor,
            blendFactor.clamp(0.0, 1.0),
          )!;
          opacity = (tailFade * 0.62 + _noise(seed * 43) * 0.08)
              .clamp(0.04, 0.65);
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: glyph,
            style: baseStyle.copyWith(
              color: glyphColor.withValues(alpha: opacity),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - (textPainter.width / 2),
            y - (textPainter.height / 2),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixBackgroundPainter old) =>
      old.progress != progress ||
      old.density != density ||
      old.toneColor != toneColor ||
      old.accentToneColor != accentToneColor;
}
