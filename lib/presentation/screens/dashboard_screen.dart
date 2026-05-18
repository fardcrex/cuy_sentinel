import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import 'widgets/bandwidth_chart_card.dart';
import 'widgets/collector_health_card.dart';
import 'widgets/recent_events_card.dart';
import 'widgets/resource_chart_card.dart';
import 'widgets/screen_header.dart';
import 'widgets/services_status_card.dart';
import 'widgets/sparkline.dart';
import 'widgets/stat_overview_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final wideLayout = width >= 1100;
        final statsColumns = AppBreakpoints.metricsColumns(width);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Dashboard',
                subtitle: 'Resumen general de la infraestructura monitoreada',
                trailing: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Últimas 24h',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Actualizar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: statsColumns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: width >= 900 ? 1.6 : 1.35,
                children: const [
                  StatOverviewCard(
                    title: 'Servicios activos',
                    value: '2 / 2',
                    caption: 'Passbolt · ChkMonitor',
                    icon: Icons.cloud_done_rounded,
                    color: AppColors.primary,
                    sparkPoints: [
                      1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                    ],
                  ),
                  StatOverviewCard(
                    title: 'Uptime promedio',
                    value: '99.9%',
                    caption: 'Últimas 72 horas',
                    icon: Icons.shield_outlined,
                    color: AppColors.primaryBright,
                    sparkPoints: [
                      0.99, 1.0, 0.85, 0.90, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                    ],
                  ),
                  StatOverviewCard(
                    title: 'Alertas activas',
                    value: '2',
                    caption: '1 crítica · 1 advertencia',
                    icon: Icons.notifications_active_rounded,
                    color: AppColors.critical,
                    sparkPoints: [
                      0.1, 0.2, 0.1, 0.5, 0.3, 0.2, 0.4, 0.6, 0.5, 0.7,
                    ],
                  ),
                  StatOverviewCard(
                    title: 'Métricas recolectadas',
                    value: '12,540',
                    caption: 'Intervalo: 5 min',
                    icon: Icons.analytics_outlined,
                    color: AppColors.secondary,
                    sparkPoints: [
                      0.4, 0.5, 0.45, 0.6, 0.55, 0.65, 0.6, 0.7, 0.68, 0.75,
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (wideLayout)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          ResourceChartCard(),
                          SizedBox(height: 20),
                          BandwidthChartCard(),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          ServicesStatusCard(),
                          SizedBox(height: 20),
                          CollectorHealthCard(),
                          SizedBox(height: 20),
                          RecentEventsCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    ServicesStatusCard(),
                    SizedBox(height: 20),
                    ResourceChartCard(),
                    SizedBox(height: 20),
                    BandwidthChartCard(),
                    SizedBox(height: 20),
                    CollectorHealthCard(),
                    SizedBox(height: 20),
                    RecentEventsCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ignore: unused_element
class _SparkPreview extends StatelessWidget {
  const _SparkPreview();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista rápida',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _SparkRow(
            imagePath: AppAssets.badgePassboltSuccess,
            name: 'Passbolt',
            cpu: 45,
            ram: 30,
            color: AppColors.primary,
            cpuPoints: const [
              0.38, 0.42, 0.44, 0.47, 0.45, 0.43, 0.46, 0.48, 0.45, 0.44,
            ],
          ),
          const SizedBox(height: 12),
          _SparkRow(
            imagePath: AppAssets.badgeServerSuccess,
            name: 'ChkMonitor',
            cpu: 12,
            ram: 25,
            color: AppColors.secondary,
            cpuPoints: const [
              0.10, 0.11, 0.12, 0.13, 0.11, 0.12, 0.13, 0.12, 0.11, 0.12,
            ],
          ),
        ],
      ),
    );
  }
}

class _SparkRow extends StatelessWidget {
  const _SparkRow({
    required this.imagePath,
    required this.name,
    required this.cpu,
    required this.ram,
    required this.color,
    required this.cpuPoints,
  });

  final String imagePath;
  final String name;
  final int cpu;
  final int ram;
  final Color color;
  final List<double> cpuPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 36, height: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'CPU $cpu%  ·  RAM $ram%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Sparkline(
            points: cpuPoints,
            color: color,
            width: 64,
            height: 28,
          ),
        ],
      ),
    );
  }
}
