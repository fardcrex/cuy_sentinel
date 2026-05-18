import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_asset_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _validUser = 'admin@cuysentinel.local';
  static const _validPassword = 'CuySentinel123';
  static const _matrixDensity = 0.8; // 0.15 (sparse) to 1.0 (dense)
  static const _warningBackgroundStartOpacity = 0.01;
  static const _warningBackgroundEndOpacity = 0.08;
  static const _matrixAlertPrimary = Color(0xFFFF5A36);
  static const _matrixAlertAccent = Color(0xFFFF2D2D);

  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController(text: _validUser);
  final _passwordController = TextEditingController(text: _validPassword);
  late final AnimationController _backgroundController;

  bool _obscurePassword = true;
  bool _rememberSession = true;
  bool _isSubmitting = false;
  bool _hasLoginError = false;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _userController.addListener(_clearLoginErrorState);
    _passwordController.addListener(_clearLoginErrorState);
  }

  void _clearLoginErrorState() {
    if (_hasLoginError && mounted) {
      setState(() => _hasLoginError = false);
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final isValidCredentials =
        _userController.text.trim() == _validUser &&
        _passwordController.text == _validPassword;

    if (!isValidCredentials) {
      setState(() {
        _isSubmitting = false;
        _hasLoginError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas. Intenta nuevamente.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = false;
      _hasLoginError = false;
    });
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = AppBreakpoints.isDesktop(width);
          final padding = AppBreakpoints.horizontalPadding(width);
          final backgroundStart = Color.lerp(
            AppColors.background,
            AppColors.warning,
            _hasLoginError ? _warningBackgroundStartOpacity : 0,
          )!;
          final backgroundEnd = Color.lerp(
            AppColors.panel,
            AppColors.critical,
            _hasLoginError ? _warningBackgroundEndOpacity : 0,
          )!;
          final matrixTone = _hasLoginError
              ? _matrixAlertPrimary
              : AppColors.primary;
          final matrixAccentTone = _hasLoginError
              ? _matrixAlertAccent
              : AppColors.primaryBright;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundStart, backgroundEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _MatrixBackgroundPainter(
                            progress: _backgroundController.value,
                            density: _matrixDensity,
                            toneColor: matrixTone,
                            accentToneColor: matrixAccentTone,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1420),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(padding),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: _LoginBrandPanel(),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 6,
                                    child: _LoginFormPanel(
                                      formKey: _formKey,
                                      userController: _userController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      rememberSession: _rememberSession,
                                      isSubmitting: _isSubmitting,
                                      onTogglePassword: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      onRememberChanged: (value) {
                                        setState(() {
                                          _rememberSession = value ?? false;
                                        });
                                      },
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _LoginFormPanel(
                                    formKey: _formKey,
                                    userController: _userController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    rememberSession: _rememberSession,
                                    isSubmitting: _isSubmitting,
                                    onTogglePassword: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    onRememberChanged: (value) {
                                      setState(() {
                                        _rememberSession = value ?? false;
                                      });
                                    },
                                    onSubmit: _submit,
                                  ),
                                  const SizedBox(height: 20),
                                  const _LoginBrandPanel(compact: true),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoginFormPanel extends StatelessWidget {
  const _LoginFormPanel({
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberSession,
    required this.isSubmitting,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberSession;
  final bool isSubmitting;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18, left: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  AppAssets.logoHorizontalPrimary,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            AppCard(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.lock_person_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Acceso seguro',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ingresa al panel de monitoreo.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: userController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Usuario o correo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu usuario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
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
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: rememberSession,
                      onChanged: onRememberChanged,
                      title: const Text('Mantener sesión activa'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Recuperación simulada. Implementación visual lista.',
                              ),
                            ),
                          );
                        },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            gradient: isSubmitting
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryBright,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                          ),
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              backgroundColor: isSubmitting
                                  ? AppColors.primary
                                  : Colors.transparent,
                              foregroundColor: AppColors.background,
                              disabledBackgroundColor: AppColors.primary,
                              disabledForegroundColor: AppColors.background,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: AppColors.primaryBright.withValues(
                                    alpha: 0.28,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
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
                              isSubmitting
                                  ? 'Validando acceso...'
                                  : 'Entrar al panel',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.background,
                                    letterSpacing: 0.1,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.info_outline,
                              color: AppColors.primaryBright,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Demo activa: usuario valido y contrasena de 8+ caracteres.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LoginStatusPill(
            icon: Icons.shield_outlined,
            label: 'Proteccion activa',
          ),
          const SizedBox(height: 18),
          Text(
            'Monitoreo en tiempo real',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Acceso directo a alertas, nodos y servicios.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 16 : 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _LoginMetricPill(label: 'Servicios', value: '24'),
                    _LoginMetricPill(label: 'Criticos', value: '03'),
                    _LoginMetricPill(label: 'Nodos', value: '128'),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Image.asset(
                    AppAssets.illustrationLoginGuard,
                    height: compact ? 220 : 360,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: _LoginFeatureCard(
                    iconPath: AppAssets.iconDashboardMonitor,
                    label: 'Vista ejecutiva',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _LoginFeatureCard(
                    iconPath: AppAssets.iconGlobalNetwork,
                    label: 'Cobertura total',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginStatusPill extends StatelessWidget {
  const _LoginStatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBright),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LoginMetricPill extends StatelessWidget {
  const _LoginMetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBright,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFeatureCard extends StatelessWidget {
  const _LoginFeatureCard({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BrandAssetIcon(
            assetPath: iconPath,
            size: 68,
            padding: const EdgeInsets.all(6),
            backgroundColor: AppColors.panel,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final spacing = 132 - (densityFactor * 62);
    final columnCount = math.max(8, (size.width / spacing).floor());
    const baseStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );

    for (var index = 0; index < columnCount; index++) {
      final seed = index + 1;
      final baseX = (index + 0.5) * size.width / columnCount;
      final drift = math.sin((progress * math.pi * 2) + index * 0.7) * 10;
      final x = baseX + drift;
      final streamLength = 4 + (index % 3);
      final travel = (progress + (index * 0.073)) % 1.0;
      final headY = travel * (size.height + 220) - 220;

      for (var segment = 0; segment < streamLength; segment++) {
        final y = headY - (segment * 26);
        if (y < -20 || y > size.height + 20) continue;

        final baseOpacity =
            (0.2 + (_noise(seed * 43) * 0.08) - (segment * 0.028)).clamp(
              0.035,
              0.24,
            );
        final binaryChar =
            ((index + segment + (progress * 10).floor()) % 2 == 0) ? '0' : '1';
        final blendFactor =
            ((segment / streamLength) * 0.45) +
            (_noise((seed * 59) + segment) * 0.35);
        final isAlertPalette = toneColor.r > toneColor.g;
        final glyphColor = Color.lerp(
          toneColor,
          accentToneColor,
          blendFactor.clamp(0.0, 1.0),
        )!;
        final opacity = isAlertPalette
            ? 1.0
            : (baseOpacity * 1.15).clamp(0.04, 0.28);
        final textPainter = TextPainter(
          text: TextSpan(
            text: binaryChar,
            style: baseStyle.copyWith(
              color: glyphColor.withValues(alpha: opacity),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - (textPainter.width / 2), y - (textPainter.height / 2)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.density != density ||
        oldDelegate.toneColor != toneColor ||
        oldDelegate.accentToneColor != accentToneColor;
  }
}
