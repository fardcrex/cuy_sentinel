import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/monitoring/domain/entities/service_status.dart';

export '../../feature/monitoring/domain/entities/service_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final ServiceStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ServiceStatus.online => ('Activo', AppColors.primary),
      ServiceStatus.offline => ('Caído', AppColors.danger),
      ServiceStatus.degraded => ('Degradado', AppColors.critical),
      ServiceStatus.warning => ('Advertencia', AppColors.warning),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
