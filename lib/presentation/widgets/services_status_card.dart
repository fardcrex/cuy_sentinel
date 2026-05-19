import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../feature/metrics/domain/entities/metric.dart';
import '../../feature/monitoring/domain/entities/monitored_service.dart';
import 'animated_number_text.dart';
import 'app_card.dart';
import 'status_badge.dart';

class ServicesStatusCard extends StatelessWidget {
  const ServicesStatusCard({
    super.key,
    required this.services,
    required this.passboltMetrics,
    required this.chkmonitorMetrics,
  });

  final List<MonitoredService> services;
  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;

  @override
  Widget build(BuildContext context) {
    final latestMetrics = {
      'svc-passbolt': passboltMetrics.firstOrNull,
      'svc-chkmonitor': chkmonitorMetrics.firstOrNull,
    };

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
          for (int i = 0; i < services.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _ServiceRow(
              imagePath: _serviceImage(services[i].id),
              accentColor: _serviceColor(services[i].id),
              name: services[i].serviceName,
              host: '${services[i].hostIp}:${services[i].snmpPort}',
              status:
                  latestMetrics[services[i].id]?.serviceStatus ??
                  ServiceStatus.warning,
              uptime: _buildUptimeWidget(
                latestMetrics[services[i].id]?.uptimeSeconds,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _serviceImage(String serviceId) => switch (serviceId) {
    'svc-passbolt' => AppAssets.miniPass,
    'svc-chkmonitor' => AppAssets.miniCheck,
    _ => AppAssets.miniPass,
  };

  static Color _serviceColor(String serviceId) => switch (serviceId) {
    'svc-passbolt' => AppColors.primary,
    'svc-chkmonitor' => AppColors.secondary,
    _ => AppColors.textSecondary,
  };

  static Widget _buildUptimeWidget(int? uptimeSeconds) {
    if (uptimeSeconds == null) return const Text('Sin datos');
    final days = uptimeSeconds ~/ Duration.secondsPerDay;
    final hours =
        (uptimeSeconds % Duration.secondsPerDay) ~/ Duration.secondsPerHour;
    if (days > 0) {
      return Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AnimatedNumberText(value: days),
          const Text('d'),
          AnimatedNumberText(value: hours),
          const Text('h'),
        ],
      );
    }
    final minutes =
        (uptimeSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
    if (hours > 0) {
      return Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AnimatedNumberText(value: hours),
          const Text('h'),
          AnimatedNumberText(value: minutes),
          const Text('min'),
        ],
      );
    }
    return Wrap(
      spacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AnimatedNumberText(value: minutes),
        const Text('min'),
      ],
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
  final Widget uptime;

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
              DefaultTextStyle(
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ) ??
                    const TextStyle(color: AppColors.textSecondary),
                child: Wrap(
                  spacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [const Text('Uptime'), uptime],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
