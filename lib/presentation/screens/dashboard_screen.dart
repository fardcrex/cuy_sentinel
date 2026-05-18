import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_asset_icon.dart';
import '../widgets/metric_chart_placeholder.dart';

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
              const _DashboardHeader(),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: statsColumns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: width >= 900 ? 1.55 : 1.3,
                children: const [
                  _StatCard(
                    'Servicios activos',
                    '2 / 2',
                    '100%',
                    AppAssets.iconSystemSettings,
                    AppColors.primary,
                  ),
                  _StatCard(
                    'Uptime promedio',
                    '99.8%',
                    'Últimas 24 horas',
                    AppAssets.iconUptimeInspectionShield,
                    AppColors.primaryBright,
                  ),
                  _StatCard(
                    'Alertas activas',
                    '1',
                    'Ver detalles',
                    AppAssets.iconAlertShield,
                    AppColors.critical,
                  ),
                  _StatCard(
                    'Métricas recolectadas',
                    '12,540',
                    'Últimas 24 horas',
                    AppAssets.iconChipMetrics,
                    AppColors.secondary,
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
                          _UsageResourcesCard(),
                          SizedBox(height: 20),
                          _BandwidthCard(),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          _ServicesStatusCard(),
                          SizedBox(height: 20),
                          _RecentAlertsCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    _UsageResourcesCard(),
                    SizedBox(height: 20),
                    _ServicesStatusCard(),
                    SizedBox(height: 20),
                    _BandwidthCard(),
                    SizedBox(height: 20),
                    _RecentAlertsCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 16,
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Resumen general de la infraestructura',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.stroke),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('12 may. 2025 - 12 may. 2025'),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
    this.title,
    this.value,
    this.caption,
    this.assetPath,
    this.color,
  );

  final String title;
  final String value;
  final String caption;
  final String assetPath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: BrandAssetIcon(
              assetPath: assetPath,
              size: 80,
              backgroundColor: color.withValues(alpha: 0.10),
              borderColor: color.withValues(alpha: 0.18),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _UsageResourcesCard extends StatelessWidget {
  const _UsageResourcesCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Uso de recursos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const _SegmentChip(label: 'Memoria', selected: true),
              const SizedBox(width: 8),
              const _SegmentChip(label: 'Disco'),
              const SizedBox(width: 8),
              const _SegmentChip(label: 'Red'),
            ],
          ),
          const SizedBox(height: 18),
          const MetricChartPlaceholder(
            points: [
              0.26,
              0.31,
              0.37,
              0.52,
              0.46,
              0.43,
              0.57,
              0.49,
              0.41,
              0.45,
              0.53,
              0.48,
              0.46,
              0.58,
              0.55,
              0.63,
              0.61,
              0.67,
            ],
            lineColor: AppColors.chartRam,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _LegendDot(color: AppColors.chartRam, label: 'Passbolt'),
              SizedBox(width: 18),
              _LegendDot(color: AppColors.chartCpu, label: 'ChkMonitor'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BandwidthCard extends StatelessWidget {
  const _BandwidthCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ancho de banda',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const MetricChartPlaceholder(
            points: [
              0.18,
              0.24,
              0.20,
              0.33,
              0.23,
              0.29,
              0.21,
              0.34,
              0.28,
              0.39,
              0.24,
              0.27,
              0.22,
              0.41,
              0.30,
              0.46,
              0.54,
              0.44,
            ],
            lineColor: AppColors.chartNetwork,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _LegendDot(color: AppColors.chartNetwork, label: 'Entrante'),
              SizedBox(width: 18),
              _LegendDot(color: AppColors.chartCpu, label: 'Saliente'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServicesStatusCard extends StatelessWidget {
  const _ServicesStatusCard();

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
          const SizedBox(height: 18),
          const _ServiceStatusRow(
            imagePath: AppAssets.badgePassboltSuccess,
            title: 'Passbolt',
            subtitle: 'Uptime 99.9%',
            status: 'Activo',
          ),
          const SizedBox(height: 12),
          const _ServiceStatusRow(
            imagePath: AppAssets.badgeServerSuccess,
            title: 'ChkMonitor',
            subtitle: 'Uptime 99.7%',
            status: 'Activo',
          ),
        ],
      ),
    );
  }
}

class _RecentAlertsCard extends StatelessWidget {
  const _RecentAlertsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alertas recientes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Ver todas')),
            ],
          ),
          const SizedBox(height: 12),
          const _AlertTile(
            title: 'Uso de memoria crítico en Passbolt',
            level: 'Crítica',
            value: '85%',
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          const _AlertTile(
            title: 'Tráfico de red elevado en ChkMonitor',
            level: 'Advertencia',
            value: '120 Mbps',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.tealGlow : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _ServiceStatusRow extends StatelessWidget {
  const _ServiceStatusRow({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 48, height: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successGlow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: const TextStyle(color: AppColors.primaryBright),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.level,
    required this.value,
    required this.color,
  });

  final String title;
  final String level;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(title),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
