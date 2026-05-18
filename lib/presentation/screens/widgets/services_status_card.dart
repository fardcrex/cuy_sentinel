import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'status_badge.dart';

class ServicesStatusCard extends StatelessWidget {
  const ServicesStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de servicios',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const _ServiceRow(
            imagePath: AppAssets.miniPass,
            accentColor: AppColors.primary,
            name: 'Passbolt',
            host: '192.168.1.10:1161',
            status: ServiceStatus.online,
            uptime: '3d 14h',
          ),
          const SizedBox(height: 12),
          const _ServiceRow(
            imagePath: AppAssets.miniCheck,
            accentColor: AppColors.secondary,
            name: 'ChkMonitor',
            host: '192.168.1.10:2161',
            status: ServiceStatus.online,
            uptime: '3d 14h',
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.imagePath,
    required this.accentColor,
    required this.name,
    required this.host,
    required this.status,
    required this.uptime,
  });

  final String imagePath;
  final Color accentColor;
  final String name;
  final String host;
  final ServiceStatus status;
  final String uptime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            height: 55,

            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(
                  host,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInactive,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: status, compact: true),
              const SizedBox(height: 4),
              Text(
                'Uptime $uptime',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
