import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/monitoring/domain/entities/collector_run.dart';
import 'animated_number_text.dart';
import 'app_card.dart';
import 'status_badge.dart';

class CollectorHealthCard extends StatelessWidget {
  const CollectorHealthCard({super.key, required this.runs});

  final List<CollectorRun> runs;

  @override
  Widget build(BuildContext context) {
    final summary = _CollectorHealthSummary.fromRuns(runs);

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
                    Text(
                      '${summary.versionLabel} · cuy_sentinel_go',
                      style: TextStyle(
                        color: AppColors.textInactive,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: summary.status),
            ],
          ),
          const SizedBox(height: 20),
          _HealthRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Ciclos completados',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedNumberText(value: summary.completedRuns),
                Text(' / '),
                AnimatedNumberText(value: summary.totalRuns),
              ],
            ),
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _HealthRow(
            icon: Icons.speed_rounded,
            label: 'Duración promedio',
            value: AnimatedNumberText(
              value: summary.averageDurationMs,
              suffix: ' ms',
            ),
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _HealthRow(
            icon: Icons.access_time_rounded,
            label: 'Última ejecución',
            value: Text(summary.lastExecutionLabel),
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          _HealthRow(
            icon: Icons.warning_amber_rounded,
            label: 'Ciclos fallidos',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedNumberText(value: summary.failedRuns),
                Text(' ('),
                AnimatedNumberText(
                  value: summary.failedRatePercent,
                  suffix: '%',
                ),
                Text(')'),
              ],
            ),
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: summary.successRate),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: animatedValue,
                  backgroundColor: AppColors.stroke,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            '${summary.successRatePercent}% tasa de éxito en últimas ${summary.totalRuns} ejecuciones',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CollectorHealthSummary {
  const _CollectorHealthSummary({
    required this.status,
    required this.versionLabel,
    required this.completedRuns,
    required this.totalRuns,
    required this.averageDurationMs,
    required this.lastExecutionLabel,
    required this.failedRuns,
    required this.failedRatePercent,
    required this.successRate,
    required this.successRatePercent,
  });

  final ServiceStatus status;
  final String versionLabel;
  final int completedRuns;
  final int totalRuns;
  final int averageDurationMs;
  final String lastExecutionLabel;
  final int failedRuns;
  final int failedRatePercent;
  final double successRate;
  final int successRatePercent;

  factory _CollectorHealthSummary.fromRuns(List<CollectorRun> runs) {
    final sortedRuns = [...runs]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final totalRuns = sortedRuns.length;
    final completedRuns = sortedRuns.where((run) => !run.isRunning).length;
    final failedRuns = sortedRuns.where((run) => !run.success).length;
    final durationSamples = sortedRuns
        .map((run) => run.durationMs)
        .whereType<int>()
        .toList();
    final averageDurationMs = durationSamples.isEmpty
        ? 0
        : (durationSamples.reduce((a, b) => a + b) / durationSamples.length)
              .round();
    final lastRun = sortedRuns.isEmpty ? null : sortedRuns.first;
    final successRate = totalRuns == 0
        ? 0.0
        : (totalRuns - failedRuns) / totalRuns;
    final successRatePercent = (successRate * 100).round();
    final failedRatePercent = totalRuns == 0
        ? 0
        : ((failedRuns / totalRuns) * 100).round();

    return _CollectorHealthSummary(
      status: _resolveStatus(lastRun),
      versionLabel: lastRun?.collectorVersion ?? '—',
      completedRuns: completedRuns,
      totalRuns: totalRuns,
      averageDurationMs: averageDurationMs,
      lastExecutionLabel: _formatRelative(
        lastRun?.finishedAt ?? lastRun?.startedAt,
      ),
      failedRuns: failedRuns,
      failedRatePercent: failedRatePercent,
      successRate: successRate,
      successRatePercent: successRatePercent,
    );
  }

  static ServiceStatus _resolveStatus(CollectorRun? run) {
    if (run == null) return ServiceStatus.offline;
    if (run.isRunning) return ServiceStatus.warning;
    if (!run.success) return ServiceStatus.degraded;
    return ServiceStatus.online;
  }

  static String _formatRelative(DateTime? dateTime) {
    if (dateTime == null) return 'Sin datos';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
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
  final Widget value;
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        DefaultTextStyle.merge(
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          child: value,
        ),
      ],
    );
  }
}
