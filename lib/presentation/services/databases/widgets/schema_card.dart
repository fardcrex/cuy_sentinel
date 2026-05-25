import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/env/app_env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/app_card.dart';

const _isPhase2 = AppEnv.apiBaseUrl != '';

class SchemaCard extends StatelessWidget {
  const SchemaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(AppAssets.iconDatabaseSync, width: 140, height: 140),
          ),
          const SizedBox(height: 14),
          Text(
            'Arquitectura de datos',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Patrón de interfaces IMonitoringRepository '
            'permite migrar de Supabase a PostgreSQL propio '
            'sin alterar la lógica del panel.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const ArchRow(
            icon: Icons.cloud_outlined,
            label: 'Supabase REST + Realtime',
            phase: 'Fase 1',
            active: !_isPhase2,
          ),
          const SizedBox(height: 10),
          const ArchRow(
            icon: Icons.dns_rounded,
            label: 'PostgreSQL + Node.js API',
            phase: 'Fase 2',
            active: _isPhase2,
          ),
          const SizedBox(height: 10),
          const ArchRow(
            icon: Icons.copy_all_rounded,
            label: 'Réplica streaming WAL',
            phase: 'Fase 2',
            active: _isPhase2,
          ),
        ],
      ),
    );
  }
}

class ArchRow extends StatelessWidget {
  const ArchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.phase,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String phase;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textInactive;
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: active ? AppColors.textPrimary : AppColors.textInactive,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            phase,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
