import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'animated_number_text.dart';
import 'app_card.dart';
import 'status_badge.dart';

class ServiceDetailCard extends StatelessWidget {
  const ServiceDetailCard({
    super.key,
    required this.name,
    required this.containerName,
    required this.host,
    required this.snmpPort,
    required this.status,
    required this.cpuPercent,
    required this.ramUsedMb,
    required this.ramTotalMb,
    required this.diskPercent,
    required this.bwInMbps,
    required this.bwOutMbps,
    required this.uptimeLabel,
    required this.imagePath,
    required this.accentColor,
  });

  final String name;
  final String containerName;
  final String host;
  final int snmpPort;
  final ServiceStatus status;
  final double cpuPercent;
  final int ramUsedMb;
  final int ramTotalMb;
  final double diskPercent;
  final double bwInMbps;
  final double bwOutMbps;
  final String uptimeLabel;
  final String imagePath;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero banner ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              height: 188,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.14),
                    accentColor.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withValues(alpha: 0.20),
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow radial behind badge
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.18),
                          accentColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  Image.asset(imagePath, width: 156, height: 156),
                ],
              ),
            ),
          ),
          // ── Info header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        containerName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textInactive,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$host : $snmpPort',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(status: status),
              ],
            ),
          ),
          // ── Metric chips ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricChip(
                  icon: Icons.memory_rounded,
                  label: 'CPU',
                  value: AnimatedNumberText(value: cpuPercent, suffix: '%'),
                  color: AppColors.chartCpu,
                ),
                _MetricChip(
                  icon: Icons.developer_board_rounded,
                  label: 'RAM',
                  value: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedNumberText(value: ramUsedMb),
                      const Text(' / '),
                      AnimatedNumberText(value: ramTotalMb),
                      const Text(' MB'),
                    ],
                  ),
                  color: AppColors.chartRam,
                ),
                _MetricChip(
                  icon: Icons.storage_rounded,
                  label: 'Disco',
                  value: AnimatedNumberText(value: diskPercent, suffix: '%'),
                  color: AppColors.chartDisk,
                ),
                _MetricChip(
                  icon: Icons.download_rounded,
                  label: 'BW In',
                  value: AnimatedNumberText(
                    value: bwInMbps,
                    suffix: ' MB/s',
                    decimalDigits: 1,
                  ),
                  color: AppColors.chartNetwork,
                ),
                _MetricChip(
                  icon: Icons.upload_rounded,
                  label: 'BW Out',
                  value: AnimatedNumberText(
                    value: bwOutMbps,
                    suffix: ' MB/s',
                    decimalDigits: 1,
                  ),
                  color: AppColors.secondary,
                ),
                _MetricChip(
                  icon: Icons.timer_outlined,
                  label: 'Uptime',
                  value: Text(uptimeLabel),
                  color: accentColor,
                ),
              ],
            ),
          ),
          // ── Progress bars ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: [
                _ProgressBar(
                  label: 'CPU',
                  value: cpuPercent / 100,
                  color: AppColors.chartCpu,
                ),
                const SizedBox(height: 10),
                _ProgressBar(
                  label: 'RAM',
                  value: ramUsedMb / ramTotalMb,
                  color: AppColors.chartRam,
                ),
                const SizedBox(height: 10),
                _ProgressBar(
                  label: 'Disco',
                  value: diskPercent / 100,
                  color: AppColors.chartDisk,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clampedValue),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Row(
          children: [
            SizedBox(
              width: 42,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: animatedValue,
                  backgroundColor: AppColors.stroke,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 38,
              child: Text(
                '${(animatedValue * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
