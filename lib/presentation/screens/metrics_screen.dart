import 'package:flutter/material.dart';

import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/metric_chart_placeholder.dart';
import 'widgets/bandwidth_chart_card.dart';
import 'widgets/metric_stats_row.dart';
import 'widgets/resource_chart_card.dart';
import 'widgets/screen_header.dart';
import 'widgets/status_badge.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Métricas',
                subtitle: 'Histórico de rendimiento recolectado vía SNMP cada 5 min',
                trailing: const _ServiceFilterRow(),
              ),
              const SizedBox(height: 24),
              const _MetricSummaryGrid(),
              const SizedBox(height: 24),
              if (isWide)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
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
                      flex: 2,
                      child: Column(
                        children: [
                          _UptimeCard(),
                          SizedBox(height: 20),
                          _SnmpHealthCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    ResourceChartCard(),
                    SizedBox(height: 20),
                    BandwidthChartCard(),
                    SizedBox(height: 20),
                    _UptimeCard(),
                    SizedBox(height: 20),
                    _SnmpHealthCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceFilterRow extends StatefulWidget {
  const _ServiceFilterRow();

  @override
  State<_ServiceFilterRow> createState() => _ServiceFilterRowState();
}

class _ServiceFilterRowState extends State<_ServiceFilterRow> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selected == i
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ['Todos', 'Passbolt', 'ChkMonitor'][i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selected == i
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricSummaryGrid extends StatelessWidget {
  const _MetricSummaryGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = AppBreakpoints.metricsColumns(constraints.maxWidth);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth >= 900 ? 1.5 : 1.3,
          children: const [
            _MetricSummaryCard(
              title: 'CPU promedio',
              passbolt: '45%',
              chkmonitor: '12%',
              icon: Icons.memory_rounded,
              color: AppColors.chartCpu,
            ),
            _MetricSummaryCard(
              title: 'RAM usada',
              passbolt: '30%',
              chkmonitor: '25%',
              icon: Icons.developer_board_rounded,
              color: AppColors.chartRam,
            ),
            _MetricSummaryCard(
              title: 'Uso de disco',
              passbolt: '58%',
              chkmonitor: '44%',
              icon: Icons.storage_rounded,
              color: AppColors.chartDisk,
            ),
            _MetricSummaryCard(
              title: 'BW entrante',
              passbolt: '2.3 MB/s',
              chkmonitor: '0.8 MB/s',
              icon: Icons.download_rounded,
              color: AppColors.chartNetwork,
            ),
          ],
        );
      },
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.title,
    required this.passbolt,
    required this.chkmonitor,
    required this.icon,
    required this.color,
  });

  final String title;
  final String passbolt;
  final String chkmonitor;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              const StatusBadge(status: ServiceStatus.online, compact: true),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _ServiceValueRow(name: 'Passbolt', value: passbolt, color: color),
          const SizedBox(height: 6),
          _ServiceValueRow(
            name: 'ChkMonitor',
            value: chkmonitor,
            color: color.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _ServiceValueRow extends StatelessWidget {
  const _ServiceValueRow({
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UptimeCard extends StatelessWidget {
  const _UptimeCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de disponibilidad',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Últimos 7 días',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          MetricChartPlaceholder(
            points: const [
              1.0, 1.0, 0.85, 0.90, 1.0, 1.0, 1.0, 1.0, 0.80, 0.87,
              1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
            ],
            lineColor: AppColors.primary,
            height: 140,
          ),
          const SizedBox(height: 14),
          MetricStatsRow(
            min: '80%',
            avg: '99.9%',
            max: '100%',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SnmpHealthCard extends StatelessWidget {
  const _SnmpHealthCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salud SNMP',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _SnmpRow(
            label: 'Passbolt :1161',
            latency: '12 ms',
            loss: '0%',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const _SnmpRow(
            label: 'ChkMonitor :2161',
            latency: '9 ms',
            loss: '0%',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.stroke, height: 1),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conectividad estable · sin pérdida de paquetes',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnmpRow extends StatelessWidget {
  const _SnmpRow({
    required this.label,
    required this.latency,
    required this.loss,
    required this.color,
  });

  final String label;
  final String latency;
  final String loss;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StatPill(label: 'Latencia', value: latency, color: color),
          const SizedBox(width: 8),
          _StatPill(label: 'Pérdida', value: loss, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
