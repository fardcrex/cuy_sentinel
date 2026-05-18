import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';

class RecentEventsCard extends StatelessWidget {
  const RecentEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Eventos recientes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '2 incidentes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _EventTile(
            service: 'ChkMonitor',
            eventType: 'Caída',
            detail: 'Servicio no disponible',
            duration: '12 min',
            timestamp: '15 may 14:23',
            color: AppColors.danger,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 10),
          const _EventTile(
            service: 'ChkMonitor',
            eventType: 'Caída',
            detail: 'Tiempo de respuesta agotado',
            duration: '6 min',
            timestamp: '13 may 09:11',
            color: AppColors.warning,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 10),
          const _EventTile(
            service: 'Passbolt',
            eventType: 'Recuperación',
            detail: 'Servicio restaurado normalmente',
            duration: '—',
            timestamp: '10 may 08:00',
            color: AppColors.primary,
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.service,
    required this.eventType,
    required this.detail,
    required this.duration,
    required this.timestamp,
    required this.color,
    required this.icon,
  });

  final String service;
  final String eventType;
  final String detail;
  final String duration;
  final String timestamp;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
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
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· $eventType',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                timestamp,
                style: const TextStyle(
                  color: AppColors.textInactive,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
