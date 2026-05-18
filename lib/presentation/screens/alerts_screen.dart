import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

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
                'Alertas',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Listado demo de eventos priorizados para el dashboard multiplataforma.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              AppBreakpoints.isDesktop(width)
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _AlertsList()),
                        SizedBox(width: 20),
                        Expanded(child: _AlertsAside()),
                      ],
                    )
                  : const Column(
                      children: [
                        _AlertsAside(),
                        SizedBox(height: 20),
                        _AlertsList(),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertsList extends StatelessWidget {
  const _AlertsList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _AlertRecord(
          title: 'Uso de memoria crítico en Passbolt',
          subtitle: 'Hace 5 min',
          level: 'Crítica',
          value: '85%',
          color: AppColors.danger,
        ),
        SizedBox(height: 14),
        _AlertRecord(
          title: 'Tráfico de red elevado en ChkMonitor',
          subtitle: 'Hace 15 min',
          level: 'Advertencia',
          value: '120 Mbps',
          color: AppColors.warning,
        ),
        SizedBox(height: 14),
        _AlertRecord(
          title: 'Latencia superior al umbral de referencia',
          subtitle: 'Hace 28 min',
          level: 'Observación',
          value: '230 ms',
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _AlertRecord extends StatelessWidget {
  const _AlertRecord({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.value,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String level;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
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
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
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
              Image.asset(AppAssets.badgeAlertWarning, width: 180, height: 180),
              const SizedBox(height: 12),
              Text(
                'Unificar alertas y métricas en una sola shell responsive evita divergencias entre web y mobile.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
              Text('Resumen'),
              SizedBox(height: 12),
              Text('1 alerta crítica activa'),
              SizedBox(height: 6),
              Text('2 advertencias recientes'),
              SizedBox(height: 6),
              Text('0 incidentes cerrados hoy'),
            ],
          ),
        ),
      ],
    );
  }
}
