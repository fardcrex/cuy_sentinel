import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';

class CollectorHealthCard extends StatelessWidget {
  const CollectorHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recolector Go',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'v1.0.2 · cuy_sentinel_go',
                      style: TextStyle(
                        color: AppColors.textInactive,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _HealthRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Ciclos completados',
            value: '147 / 150',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const _HealthRow(
            icon: Icons.speed_rounded,
            label: 'Duración promedio',
            value: '234 ms',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          const _HealthRow(
            icon: Icons.access_time_rounded,
            label: 'Última ejecución',
            value: 'Hace 3 min',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const _HealthRow(
            icon: Icons.warning_amber_rounded,
            label: 'Ciclos fallidos',
            value: '3 (2%)',
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 147 / 150,
              backgroundColor: AppColors.stroke,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '98% tasa de éxito en últimas 150 ejecuciones',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
