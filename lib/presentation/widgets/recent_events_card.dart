import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../feature/monitoring/domain/entities/service_event.dart';
import 'animated_number_text.dart';
import 'app_card.dart';

class RecentEventsCard extends StatelessWidget {
  const RecentEventsCard({
    super.key,
    required this.events,
    required this.services,
  });

  final List<ServiceEvent> events;
  final List<MonitoredService> services;

  @override
  Widget build(BuildContext context) {
    final serviceNames = {
      for (final service in services) service.id: service.serviceName,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Eventos recientes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Wrap(
                    spacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AnimatedNumberText(value: events.length),
                      const Text('incidentes'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            const Text(
              'Sin eventos recientes',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            for (int i = 0; i < events.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _EventTile(
                service:
                    serviceNames[events[i].serviceId] ?? events[i].serviceId,
                eventType: _eventTypeLabel(events[i].eventType),
                detail: events[i].cause ?? 'Sin detalle',
                duration: _buildDurationWidget(events[i].durationSeconds),
                timestamp: _formatTimestamp(events[i].createdAt),
                color: _eventColor(events[i].eventType),
                icon: _eventIcon(events[i].eventType),
              ),
            ],
        ],
      ),
    );
  }

  static String _eventTypeLabel(ServiceEventType type) => switch (type) {
    ServiceEventType.down => 'Caída',
    ServiceEventType.recovered => 'Recuperación',
    ServiceEventType.degraded => 'Degradación',
    ServiceEventType.warning => 'Advertencia',
  };

  static Color _eventColor(ServiceEventType type) => switch (type) {
    ServiceEventType.down => AppColors.danger,
    ServiceEventType.recovered => AppColors.primary,
    ServiceEventType.degraded => AppColors.critical,
    ServiceEventType.warning => AppColors.warning,
  };

  static IconData _eventIcon(ServiceEventType type) => switch (type) {
    ServiceEventType.down => Icons.arrow_downward_rounded,
    ServiceEventType.recovered => Icons.check_circle_outline_rounded,
    ServiceEventType.degraded => Icons.trending_down_rounded,
    ServiceEventType.warning => Icons.warning_amber_rounded,
  };

  static Widget _buildDurationWidget(int? seconds) {
    if (seconds == null || seconds <= 0) return const Text('—');
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AnimatedNumberText(value: minutes),
          const Text('min'),
        ],
      );
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return Wrap(
      spacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AnimatedNumberText(value: hours),
        const Text('h'),
        AnimatedNumberText(value: remainingMinutes),
        const Text('min'),
      ],
    );
  }

  static String _formatTimestamp(DateTime dateTime) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day} ${months[dateTime.month - 1]} $hour:$minute';
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
  final Widget duration;
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
              DefaultTextStyle(
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                child: duration,
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
