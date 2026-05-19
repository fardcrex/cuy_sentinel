import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class InfrastructureCard extends StatelessWidget {
  const InfrastructureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: AppColors.primaryBright,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Infraestructura SNMP',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              InfraChip(
                icon: Icons.dns_rounded,
                label: 'Ubuntu 24.04 LTS',
                color: AppColors.secondary,
              ),
              InfraChip(
                icon: Icons.precision_manufacturing_rounded,
                label: 'Docker Compose',
                color: AppColors.primaryBright,
              ),
              InfraChip(
                icon: Icons.wifi_tethering_rounded,
                label: 'SNMP v2c',
                color: AppColors.primary,
              ),
              InfraChip(
                icon: Icons.storage_rounded,
                label: 'Supabase (Fase 1)',
                color: AppColors.warning,
              ),
              InfraChip(
                icon: Icons.code_rounded,
                label: 'Go Collector',
                color: AppColors.chartCpu,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfraChip extends StatelessWidget {
  const InfraChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
