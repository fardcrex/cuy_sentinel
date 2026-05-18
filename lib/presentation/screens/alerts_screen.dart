import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import 'widgets/alert_threshold_tile.dart';
import 'widgets/incident_record_tile.dart';
import 'widgets/screen_header.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

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
                title: 'Alertas',
                subtitle: 'Umbrales derivados de métricas SNMP + historial de incidentes',
                trailing: const _AlertSummaryBadges(),
              ),
              const SizedBox(height: 24),
              if (isWide)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _AlertsSection(),
                          SizedBox(height: 24),
                          _IncidentsSection(),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _AlertsAside(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    _AlertsAside(),
                    SizedBox(height: 24),
                    _AlertsSection(),
                    SizedBox(height: 24),
                    _IncidentsSection(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertSummaryBadges extends StatelessWidget {
  const _AlertSummaryBadges();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _SummaryBadge(label: '1 crítica', color: AppColors.danger),
        _SummaryBadge(label: '1 advertencia', color: AppColors.warning),
        _SummaryBadge(label: '0 cerradas hoy', color: AppColors.textSecondary),
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas activas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const AlertThresholdTile(
          service: 'Passbolt',
          metric: 'Uso de memoria (RAM)',
          currentValue: '85%',
          threshold: '80%',
          severity: AlertSeverity.critical,
          timestamp: 'Hace 5 min',
        ),
        const SizedBox(height: 12),
        const AlertThresholdTile(
          service: 'ChkMonitor',
          metric: 'Ancho de banda entrante',
          currentValue: '120 Mbps',
          threshold: '100 Mbps',
          severity: AlertSeverity.warning,
          timestamp: 'Hace 15 min',
        ),
        const SizedBox(height: 12),
        const AlertThresholdTile(
          service: 'Passbolt',
          metric: 'Latencia de respuesta SNMP',
          currentValue: '230 ms',
          threshold: '200 ms',
          severity: AlertSeverity.info,
          timestamp: 'Hace 28 min',
        ),
      ],
    );
  }
}

class _IncidentsSection extends StatelessWidget {
  const _IncidentsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de incidentes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const IncidentRecordTile(
          service: 'ChkMonitor',
          type: IncidentType.down,
          startTime: '15 may 14:23',
          endTime: '15 may 14:35',
          duration: '12 min',
          cause: 'Servicio no disponible — tiempo de respuesta agotado',
        ),
        const SizedBox(height: 12),
        const IncidentRecordTile(
          service: 'ChkMonitor',
          type: IncidentType.down,
          startTime: '13 may 09:11',
          endTime: '13 may 09:17',
          duration: '6 min',
          cause: 'Reinicio del contenedor detectado vía SNMP',
        ),
        const SizedBox(height: 12),
        const IncidentRecordTile(
          service: 'Passbolt',
          type: IncidentType.recovered,
          startTime: '10 may 07:55',
          endTime: '10 may 08:00',
          duration: '5 min',
          cause: 'Recuperación automática tras actualización de imagen',
        ),
      ],
    );
  }
}

class _AlertsAside extends StatelessWidget {
  const _AlertsAside();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              Image.asset(
                AppAssets.badgeAlertWarning,
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 12),
              Text(
                'Las alertas se derivan automáticamente al superar los umbrales '
                'definidos sobre las métricas SNMP recolectadas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Umbrales configurados',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(height: 14),
              _ThresholdRow(metric: 'RAM', threshold: '> 80%', color: AppColors.danger),
              SizedBox(height: 8),
              _ThresholdRow(metric: 'CPU', threshold: '> 75%', color: AppColors.warning),
              SizedBox(height: 8),
              _ThresholdRow(metric: 'Disco', threshold: '> 85%', color: AppColors.warning),
              SizedBox(height: 8),
              _ThresholdRow(metric: 'BW', threshold: '> 100 Mbps', color: AppColors.secondary),
              SizedBox(height: 8),
              _ThresholdRow(metric: 'Latencia', threshold: '> 200 ms', color: AppColors.secondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({
    required this.metric,
    required this.threshold,
    required this.color,
  });

  final String metric;
  final String threshold;
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            metric,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        Text(
          threshold,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
