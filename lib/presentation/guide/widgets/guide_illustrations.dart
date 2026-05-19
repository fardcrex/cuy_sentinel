import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/metric_chart_placeholder.dart';

// ── Static data ────────────────────────────────────────────────────────────────

const _cpuPoints = <double?>[
  0.35, 0.48, 0.45, 0.62, 0.58, 0.71, 0.65, 0.78, 0.72, 0.68, 0.74, 0.67,
];
const _bwPoints = <double?>[
  0.20, 0.35, 0.28, 0.45, 0.38, 0.52, 0.48, 0.65, 0.55, 0.42, 0.58, 0.50,
];

// ── Dashboard ──────────────────────────────────────────────────────────────────

class StatCardsIllustration extends StatelessWidget {
  const StatCardsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StatCard(value: '2/2', label: 'activos', color: AppColors.primary),
        SizedBox(width: 8),
        _StatCard(value: '99%', label: 'uptime', color: AppColors.primaryBright),
        SizedBox(width: 8),
        _StatCard(value: '0', label: 'alertas', color: AppColors.warning),
        SizedBox(width: 8),
        _StatCard(value: '240', label: 'métricas', color: AppColors.secondary),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceChartIllustration extends StatelessWidget {
  const ResourceChartIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const MetricChartPlaceholder(
      points: _cpuPoints,
      lineColor: AppColors.chartCpu,
      height: 92,
    );
  }
}

class BandwidthChartIllustration extends StatelessWidget {
  const BandwidthChartIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const MetricChartPlaceholder(
      points: _bwPoints,
      lineColor: AppColors.chartNetwork,
      height: 92,
    );
  }
}

class ServiceStatusIllustration extends StatelessWidget {
  const ServiceStatusIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ServiceStatusCard(
            name: 'Passbolt',
            port: ':1161',
            uptime: '99.8%',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ServiceStatusCard(
            name: 'ChkMonitor',
            port: ':2161',
            uptime: '100%',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _ServiceStatusCard extends StatelessWidget {
  const _ServiceStatusCard({
    required this.name,
    required this.port,
    required this.uptime,
    required this.color,
  });

  final String name;
  final String port;
  final String uptime;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'online',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'SNMP $port',
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 3),
          Text(
            'Uptime: $uptime',
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class CollectorHealthIllustration extends StatelessWidget {
  const CollectorHealthIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Agente activo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Última ejecución: hace 3 min · 0 errores',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentEventsIllustration extends StatelessWidget {
  const RecentEventsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EventRow(
            text: 'Passbolt · SNMP online',
            time: 'hace 2 min',
            color: AppColors.primary,
          ),
          SizedBox(height: 5),
          _EventRow(
            text: 'ChkMonitor · CPU pico 78%',
            time: 'hace 18 min',
            color: AppColors.warning,
          ),
          SizedBox(height: 5),
          _EventRow(
            text: 'Passbolt · CPU recuperado',
            time: 'hace 1 h',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.text,
    required this.time,
    required this.color,
  });

  final String text;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: BorderSide(color: AppColors.stroke),
          right: BorderSide(color: AppColors.stroke),
          bottom: BorderSide(color: AppColors.stroke),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Servicios ──────────────────────────────────────────────────────────────────

class ServiceCardsIllustration extends StatelessWidget {
  const ServiceCardsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ServiceDetailCard(
            name: 'Passbolt',
            version: 'v4.8.0',
            port: '1161',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ServiceDetailCard(
            name: 'ChkMonitor',
            version: 'v2.1.3',
            port: '2161',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _ServiceDetailCard extends StatelessWidget {
  const _ServiceDetailCard({
    required this.name,
    required this.version,
    required this.port,
    required this.color,
  });

  final String name;
  final String version;
  final String port;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 10, color: AppColors.stroke),
          _kv('Puerto SNMP', ':$port'),
          const SizedBox(height: 3),
          _kv('Versión', version),
          const SizedBox(height: 3),
          _kv('Uptime', '99.8%'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            v,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
}

class InfraCardIllustration extends StatelessWidget {
  const InfraCardIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          const Icon(Icons.dns_rounded, color: AppColors.textSecondary, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Docker Compose',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: const [
                    _ContainerChip('passbolt'),
                    _ContainerChip('chkmonitor'),
                    _ContainerChip('redis'),
                    _ContainerChip('nginx'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContainerChip extends StatelessWidget {
  const _ContainerChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SupabaseCardIllustration extends StatelessWidget {
  const SupabaseCardIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Supabase',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '1 activa',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: const [
              _TableChip('users'),
              _TableChip('monitored_services'),
              _TableChip('metrics'),
              _TableChip('service_events'),
              _TableChip('collector_runs'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableChip extends StatelessWidget {
  const _TableChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class SchemaCardIllustration extends StatelessWidget {
  const SchemaCardIllustration({super.key});

  static const _tables = [
    (Icons.people_outline_rounded, 'users'),
    (Icons.dns_outlined, 'monitored_services'),
    (Icons.analytics_outlined, 'metrics'),
    (Icons.event_note_outlined, 'service_events'),
    (Icons.sensors_outlined, 'collector_runs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _tables.length; i++) ...[
            if (i > 0)
              Container(height: 1, color: AppColors.stroke),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(_tables[i].$1, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    _tables[i].$2,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Phase2DbIllustration extends StatelessWidget {
  const Phase2DbIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _PgCard(
            label: 'PostgreSQL\nPrimario',
            badge: 'Fase 2',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _PgCard(
            label: 'Réplica\nstreaming',
            badge: 'WAL',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _PgCard extends StatelessWidget {
  const _PgCard({
    required this.label,
    required this.badge,
    required this.color,
  });

  final String label;
  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Métricas ───────────────────────────────────────────────────────────────────

class MetricsFiltersIllustration extends StatelessWidget {
  const MetricsFiltersIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros de rango temporal y servicio',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            _FilterChip('1h', active: true),
            SizedBox(width: 6),
            _FilterChip('6h'),
            SizedBox(width: 6),
            _FilterChip('24h'),
            SizedBox(width: 6),
            _FilterChip('7d'),
            Spacer(),
            _FilterChip('Passbolt', active: true),
            SizedBox(width: 6),
            _FilterChip('ChkMonitor'),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, {this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            active ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              active ? AppColors.primary.withValues(alpha: 0.5) : AppColors.stroke,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: active ? AppColors.primary : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class MetricsSummaryIllustration extends StatelessWidget {
  const MetricsSummaryIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _MetricSummaryCard('CPU', '48%', '35%', '67%', AppColors.chartCpu),
        SizedBox(width: 6),
        _MetricSummaryCard('RAM', '512 MB', '480 MB', '620 MB', AppColors.chartRam),
        SizedBox(width: 6),
        _MetricSummaryCard('Disco', '72%', '70%', '75%', AppColors.chartDisk),
        SizedBox(width: 6),
        _MetricSummaryCard('SNMP', '12 ms', '8 ms', '22 ms', AppColors.chartNetwork),
      ],
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard(
    this.label,
    this.prom,
    this.min,
    this.max,
    this.color,
  );

  final String label;
  final String prom;
  final String min;
  final String max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              prom,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '↓ $min',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '↑ $max',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UptimeTimelineIllustration extends StatelessWidget {
  const UptimeTimelineIllustration({super.key});

  static const _blocks = [
    true, true, true, true, true, true, false, true,
    true, true, true, true, true, true, true, true,
    true, true, true, false, true, true, true, true,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Timeline de uptime — últimos 7 días',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final online in _blocks) ...[
              Expanded(
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: online
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : AppColors.danger.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 2),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '7 días atrás',
              style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
            ),
            Text(
              'ahora',
              style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class SnmpHealthIllustration extends StatelessWidget {
  const SnmpHealthIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _HealthStat(
            label: 'Latencia\npromedio',
            value: '12 ms',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HealthStat(
            label: 'Latencia\nmáxima',
            value: '22 ms',
            color: AppColors.warning,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HealthStat(
            label: 'Paquetes\nperdidos',
            value: '0.2%',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _HealthStat extends StatelessWidget {
  const _HealthStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alertas ────────────────────────────────────────────────────────────────────

class AlertBadgesIllustration extends StatelessWidget {
  const AlertBadgesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _AlertBadge('2 Críticas', AppColors.danger),
            SizedBox(width: 10),
            _AlertBadge('3 Advertencias', AppColors.warning),
            SizedBox(width: 10),
            _AlertBadge('5 Totales', AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Contadores de alertas activas en el header',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AlertListIllustration extends StatelessWidget {
  const AlertListIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AlertItemRow(
            text: 'Passbolt · CPU > 80%',
            value: '82%',
            time: 'hace 5 min',
            color: AppColors.danger,
          ),
          SizedBox(height: 5),
          _AlertItemRow(
            text: 'ChkMonitor · RAM > 75%',
            value: '77%',
            time: 'hace 12 min',
            color: AppColors.warning,
          ),
          SizedBox(height: 5),
          _AlertItemRow(
            text: 'Passbolt · Disco > 70%',
            value: '73%',
            time: 'hace 1 h',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _AlertItemRow extends StatelessWidget {
  const _AlertItemRow({
    required this.text,
    required this.value,
    required this.time,
    required this.color,
  });

  final String text;
  final String value;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: BorderSide(color: AppColors.stroke),
          right: BorderSide(color: AppColors.stroke),
          bottom: BorderSide(color: AppColors.stroke),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class IncidentsIllustration extends StatelessWidget {
  const IncidentsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IncidentRow(
          cause: 'Passbolt offline',
          when: '22/05 14:30',
          duration: '8 min',
          color: AppColors.danger,
        ),
        SizedBox(height: 6),
        _IncidentRow(
          cause: 'CPU sostenido > 85%',
          when: '21/05 09:15',
          duration: '23 min',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _IncidentRow extends StatelessWidget {
  const _IncidentRow({
    required this.cause,
    required this.when,
    required this.duration,
    required this.color,
  });

  final String cause;
  final String when;
  final String duration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cause,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$when · duración $duration',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'resuelto',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThresholdsIllustration extends StatelessWidget {
  const ThresholdsIllustration({super.key});

  static const _rows = [
    ('CPU %', '> 80', AppColors.danger),
    ('RAM %', '> 75', AppColors.warning),
    ('Disco %', '> 70', AppColors.warning),
    ('Latencia SNMP', '> 100 ms', AppColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          _ThresholdRow2(_rows[i].$1, _rows[i].$2, _rows[i].$3),
        ],
      ],
    );
  }
}

class _ThresholdRow2 extends StatelessWidget {
  const _ThresholdRow2(this.metric, this.threshold, this.color);

  final String metric;
  final String threshold;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              threshold,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Usuarios ───────────────────────────────────────────────────────────────────

class OnlineBadgeIllustration extends StatelessWidget {
  const OnlineBadgeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '2 usuarios en línea',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sesiones activas en tiempo real',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class UserListIllustration extends StatelessWidget {
  const UserListIllustration({super.key});

  static const _users = [
    ('Jair Conislla', 'Admin', true),
    ('Daniel Rojas', 'Viewer', true),
    ('Jheampierre Ralli', 'Viewer', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.stroke)),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Usuario',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Rol',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          for (final u in _users)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.stroke)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        u.$1.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      u.$1,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      u.$2,
                      style: TextStyle(
                        fontSize: 10,
                        color: u.$2 == 'Admin'
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: u.$3 ? AppColors.primary : AppColors.textInactive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SessionStatsIllustration extends StatelessWidget {
  const SessionStatsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _SessionStat(
            label: 'Logins\nhoy',
            value: '8',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _SessionStat(
            label: 'Sesión\npromedio',
            value: '42 min',
            color: AppColors.secondary,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _SessionStat(
            label: 'Hora\npico',
            value: '10:00',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _SessionStat extends StatelessWidget {
  const _SessionStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AccessLogIllustration extends StatelessWidget {
  const AccessLogIllustration({super.key});

  static const _entries = [
    ('jair', 'login', '10:32', true),
    ('daniel', 'login', '10:45', true),
    ('jheampierre', 'logout', '11:20', false),
    ('jair', 'password_change', '11:35', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _entries.length; i++) ...[
            if (i > 0) Container(height: 1, color: AppColors.stroke),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _entries[i].$4 == true
                          ? AppColors.primary
                          : _entries[i].$4 == false
                              ? AppColors.textSecondary
                              : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _entries[i].$1,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _entries[i].$2,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    _entries[i].$3,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
