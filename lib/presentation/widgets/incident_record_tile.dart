import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_card.dart';

enum IncidentType { down, recovered, degraded }

class IncidentRecordTile extends StatelessWidget {
  const IncidentRecordTile({
    super.key,
    required this.service,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.cause,
  });

  final String service;
  final IncidentType type;
  final String startTime;
  final String endTime;
  final String duration;
  final String cause;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      IncidentType.down      => AppColors.danger,
      IncidentType.recovered => AppColors.primary,
      IncidentType.degraded  => AppColors.warning,
    };
    final icon = switch (type) {
      IncidentType.down      => Icons.arrow_downward_rounded,
      IncidentType.recovered => Icons.check_rounded,
      IncidentType.degraded  => Icons.warning_amber_rounded,
    };
    final typeLabel = switch (type) {
      IncidentType.down      => 'Caída',
      IncidentType.recovered => 'Recuperación',
      IncidentType.degraded  => 'Degradado',
    };

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· $typeLabel',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cause,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.play_arrow_rounded,
                      text: 'Inicio: $startTime',
                    ),
                    _InfoChip(icon: Icons.stop_rounded, text: 'Fin: $endTime'),
                    _InfoChip(
                      icon: Icons.hourglass_bottom_rounded,
                      text: 'Duración: $duration',
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
