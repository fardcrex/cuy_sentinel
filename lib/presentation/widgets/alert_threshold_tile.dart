import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_card.dart';

enum AlertSeverity { nuclear, critical, warning, info }

class AlertThresholdTile extends StatelessWidget {
  const AlertThresholdTile({
    super.key,
    required this.service,
    required this.metric,
    required this.currentValue,
    required this.threshold,
    required this.severity,
    required this.timestamp,
    this.isResolving = false,
    this.isResolved = false,
    this.onResolve,
  });

  final String service;
  final String metric;
  final String currentValue;
  final String threshold;
  final AlertSeverity severity;
  final String timestamp;
  final bool isResolving;
  final bool isResolved;
  final VoidCallback? onResolve;

  Color get _color => isResolved
      ? AppColors.primary
      : switch (severity) {
          AlertSeverity.nuclear => const Color(0xFFFF0040),
          AlertSeverity.critical => AppColors.danger,
          AlertSeverity.warning => AppColors.warning,
          AlertSeverity.info => AppColors.secondary,
        };

  String get _severityLabel => isResolved
      ? 'Resuelta'
      : switch (severity) {
          AlertSeverity.nuclear => 'Nuclear',
          AlertSeverity.critical => 'Crítica',
          AlertSeverity.warning => 'Advertencia',
          AlertSeverity.info => 'Observación',
        };

  IconData get _icon => isResolved
      ? Icons.check_circle_rounded
      : switch (severity) {
          AlertSeverity.nuclear => Icons.crisis_alert_rounded,
          AlertSeverity.critical => Icons.error_outline_rounded,
          AlertSeverity.warning => Icons.warning_amber_rounded,
          AlertSeverity.info => Icons.info_outline_rounded,
        };

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _severityLabel,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.stroke.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$metric supera el umbral configurado',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ValueBadge(
                      label: 'Actual',
                      value: currentValue,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    _ValueBadge(
                      label: 'Umbral',
                      value: threshold,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textInactive,
                ),
              ),
              if (onResolve != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: isResolving || isResolved ? null : onResolve,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isResolving || isResolved
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : AppColors.stroke.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: isResolving || isResolved
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.28),
                            )
                          : null,
                    ),
                    child: Center(
                      child: isResolving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : isResolved
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Resuelta',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Cerrar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
