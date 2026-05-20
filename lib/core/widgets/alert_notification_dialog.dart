import 'package:flutter/material.dart';

import '../../feature/alerts/domain/entities/alert_event.dart';
import '../../feature/alerts/domain/entities/alert_severity.dart';
import '../assets/app_assets.dart';
import '../theme/app_colors.dart';

const _nuclearColor = Color(0xFFFF0040);

void showAlertNotificationDialog(BuildContext context, AlertEvent event) {
  showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: _barrierColor(event.severity),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => _AlertDialogPage(event: event),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.88,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

Color _barrierColor(AlertSeverity severity) => switch (severity) {
  AlertSeverity.nuclear => Colors.black.withValues(alpha: 0.88),
  AlertSeverity.critical => Colors.black.withValues(alpha: 0.72),
  _ => Colors.black.withValues(alpha: 0.60),
};

class _AlertDialogPage extends StatelessWidget {
  const _AlertDialogPage({required this.event});

  final AlertEvent event;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isMobile = screen.width < 600;

    final alignment = event.severity == AlertSeverity.info
        ? const Alignment(0, -0.5)
        : Alignment.center;

    final maxHeight = event.severity == AlertSeverity.nuclear
        ? screen.height * 0.52
        : screen.height * 0.32;

    final maxWidth = event.severity == AlertSeverity.nuclear
        ? (isMobile ? screen.width * 0.92 : 660.0)
        : (isMobile ? screen.width * 0.90 : 420.0);

    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              maxWidth: maxWidth,
            ),
            child: AlertDialogCard(event: event),
          ),
        ),
      ),
    );
  }
}

class AlertDialogCard extends StatelessWidget {
  const AlertDialogCard({super.key, required this.event});

  final AlertEvent event;

  @override
  Widget build(BuildContext context) {
    return switch (event.severity) {
      AlertSeverity.nuclear => _NuclearCard(event: event),
      AlertSeverity.critical => _SeverityCard(
        event: event,
        accentColor: AppColors.danger,
        imagePath: AppAssets.badgeAlertWarning,
        imageSize: 64,
        title: 'Alerta Crítica',
      ),
      AlertSeverity.warning => _SeverityCard(
        event: event,
        accentColor: AppColors.warning,
        imagePath: AppAssets.iconAlertShield,
        imageSize: 64,
        title: 'Advertencia',
      ),
      AlertSeverity.info => _InfoCard(event: event),
    };
  }
}

// ─── Nuclear ──────────────────────────────────────────────────────────────────

class _NuclearCard extends StatelessWidget {
  const _NuclearCard({required this.event});

  final AlertEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _nuclearColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _nuclearColor.withValues(alpha: 0.35),
            blurRadius: 48,
            spreadRadius: 4,
          ),
          const BoxShadow(
            color: Colors.black,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: _nuclearColor.withValues(alpha: 0.14),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: _nuclearColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'ALERTA NUCLEAR DETECTADA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _nuclearColor,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Body: imagen izquierda (altura libre), texto+botón derecha
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Columna izquierda — ilustración portrait 256×384
                  SizedBox(
                    width: 256,

                    child: Image.asset(
                      AppAssets.illustrationNuclear,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.center,
                    ),
                  ),
                  // Columna derecha — textos y botón
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'El servidor ${event.serviceName} ha recibido un ataque nuclear.',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sistemas comprometidos. Respuesta de emergencia requerida — evacúe el entorno inmediatamente.',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(),
                              style: FilledButton.styleFrom(
                                backgroundColor: _nuclearColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'ENTENDIDO',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Severity card (critical / warning) ──────────────────────────────────────

class _SeverityCard extends StatelessWidget {
  const _SeverityCard({
    required this.event,
    required this.accentColor,
    required this.imagePath,
    required this.imageSize,
    required this.title,
  });

  final AlertEvent event;
  final Color accentColor;
  final String imagePath;
  final double imageSize;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.20),
            blurRadius: 32,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                imagePath,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.serviceName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: '${event.metricName}  '),
                  TextSpan(
                    text: '${event.currentValue} > ${event.thresholdValue}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.event});

  final AlertEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      event.serviceName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${event.metricName}: ${event.currentValue}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
