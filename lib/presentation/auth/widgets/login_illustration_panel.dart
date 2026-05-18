import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class LoginIllustrationPanel extends StatelessWidget {
  const LoginIllustrationPanel({super.key, required this.hasError});

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
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
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
