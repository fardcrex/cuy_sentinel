import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_asset_icon.dart';
import '../widgets/metric_chart_placeholder.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Métricas',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholders visuales para memoria, disco y salud general.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: AppBreakpoints.metricsColumns(width),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: width >= 900 ? 1.35 : 1.15,
                children: const [
                  _MetricOverviewCard(
                    title: 'Memoria',
                    value: '46%',
                    accent: AppColors.secondary,
                    assetPath: AppAssets.iconDashboardMonitor,
                  ),
                  _MetricOverviewCard(
                    title: 'Disco',
                    value: '62%',
                    accent: AppColors.warning,
                    assetPath: AppAssets.iconDatabaseSync,
                  ),
                  _MetricOverviewCard(
                    title: 'Red',
                    value: '128 Mbps',
                    accent: AppColors.primary,
                    assetPath: AppAssets.iconGlobalNetwork,
                  ),
                  _MetricOverviewCard(
                    title: 'SNMP',
                    value: 'Activo',
                    accent: AppColors.primaryBright,
                    assetPath: AppAssets.iconUptimeInspectionShield,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppBreakpoints.isDesktop(width)
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _MetricChartCard()),
                        SizedBox(width: 20),
                        Expanded(child: _MetricsSidePanel()),
                      ],
                    )
                  : const Column(
                      children: [
                        _MetricChartCard(),
                        SizedBox(height: 20),
                        _MetricsSidePanel(),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricOverviewCard extends StatelessWidget {
  const _MetricOverviewCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.assetPath,
  });

  final String title;
  final String value;
  final Color accent;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Center(
            child: BrandAssetIcon(
              assetPath: assetPath,
              size: 80,
              backgroundColor: accent.withValues(alpha: 0.10),
              borderColor: accent.withValues(alpha: 0.18),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChartCard extends StatelessWidget {
  const _MetricChartCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia de memoria',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const MetricChartPlaceholder(
            points: [
              0.35,
              0.32,
              0.42,
              0.38,
              0.45,
              0.48,
              0.41,
              0.50,
              0.54,
              0.47,
              0.52,
              0.58,
              0.56,
              0.61,
              0.57,
              0.64,
            ],
            lineColor: AppColors.secondary,
            height: 240,
          ),
        ],
      ),
    );
  }
}

class _MetricsSidePanel extends StatelessWidget {
  const _MetricsSidePanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado SNMP'),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Conectividad estable y sin pérdida de paquetes.',
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.verified_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            children: [
              Image.asset(AppAssets.badgeSnmpSuccess, width: 150, height: 150),
              const SizedBox(height: 12),
              Text(
                'Diseñado para crecer a un dashboard operativo completo en web y mobile.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
