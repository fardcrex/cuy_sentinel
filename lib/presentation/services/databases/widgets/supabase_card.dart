import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/animated_number_text.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';
import '../database_model.dart';

class SupabaseCard extends StatelessWidget {
  const SupabaseCard({super.key, required this.model, this.enabled = true});

  final DatabaseHealthModel model;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);
    if (enabled) return card;

    return Stack(
      children: [
        Opacity(opacity: 0.35, child: card),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.panel.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.stroke.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textInactive,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Text(
                      'Migrado a Fase 2',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reemplazado por PostgreSQL auto-hospedado',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textInactive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 18,
                    left: 20,
                    child: Text(
                      'Supabase',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 20,
                    child: StatusBadge(status: model.status),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.18),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppAssets.badgeBdSuccess,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'PostgreSQL 15 · Cloud',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'us-east-1 · cuy-sentinel-db',
                        style: TextStyle(
                          color: AppColors.textInactive,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Fase 1',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                DbChip(
                  icon: Icons.speed_rounded,
                  label: 'Latencia',
                  value: AnimatedNumberText(
                    value: model.latencyMs,
                    suffix: ' ms',
                  ),
                  color: AppColors.primary,
                ),
                DbChip(
                  icon: Icons.storage_rounded,
                  label: 'Almacenamiento',
                  value: AnimatedNumberText(
                    value: model.storageMb,
                    suffix: ' MB',
                  ),
                  color: AppColors.chartRam,
                ),
                DbChip(
                  icon: Icons.cached_rounded,
                  label: 'Cache hit',
                  value: AnimatedNumberText(
                    value: model.cacheHitPercent,
                    suffix: '%',
                    decimalDigits: 1,
                  ),
                  color: AppColors.secondary,
                ),
                DbChip(
                  icon: Icons.link_rounded,
                  label: 'Conexiones',
                  value: AnimatedNumberText(
                    value: model.activeConnections,
                    suffix: ' activas',
                  ),
                  color: AppColors.chartNetwork,
                ),
                DbChip(
                  icon: Icons.table_chart_outlined,
                  label: 'Tablas',
                  value: AnimatedNumberText(value: model.totalTables),
                  color: AppColors.chartDisk,
                ),
                DbChip(
                  icon: Icons.numbers_rounded,
                  label: 'Filas totales',
                  value: AnimatedNumberText(
                    value: model.totalRows,
                    groupThousands: true,
                  ),
                  color: AppColors.primaryBright,
                ),
                DbChip(
                  icon: Icons.access_time_rounded,
                  label: 'Última escritura',
                  value: Text(model.lastWrite),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Conteo de filas por tabla',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                for (int i = 0; i < model.tableStats.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  DbTableRow(stat: model.tableStats[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DbChip extends StatelessWidget {
  const DbChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Widget value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                child: value,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DbTableRow extends StatelessWidget {
  const DbTableRow({super.key, required this.stat});

  final TableStatModel stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stat.color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: stat.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.name,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  stat.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedNumberText(
            value: stat.rows,
            groupThousands: true,
            style: TextStyle(
              color: stat.color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            ' filas',
            style: TextStyle(color: AppColors.textInactive, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
