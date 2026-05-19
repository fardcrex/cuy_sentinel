import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'screen_miniature/alerts_miniature.dart';
import 'screen_miniature/dashboard_miniature.dart';
import 'screen_miniature/metrics_miniature.dart';
import 'screen_miniature/services_miniature.dart';
import 'screen_miniature/users_miniature.dart';

class GuideSummaryTab extends StatelessWidget {
  const GuideSummaryTab({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final columns = AppBreakpoints.isDesktop(width)
            ? 5
            : AppBreakpoints.isTablet(width)
                ? 3
                : 2;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Cuy Sentinel',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Guía funcional de cada sección. Toca una card para ir al detalle.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _SummaryGrid(
                tabController: tabController,
                columns: columns,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _InfoChip(label: '2 servicios monitoreados'),
                  _InfoChip(label: 'Recolección cada 5 min'),
                  _InfoChip(label: 'SNMP'),
                  _InfoChip(label: '2 fases de arquitectura'),
                  _InfoChip(label: 'Passbolt · ChkMonitor'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.tabController,
    required this.columns,
  });

  final TabController tabController;
  final int columns;

  static final _cards = [
    _SummaryCardData(
      miniature: const DashboardMiniature(),
      name: 'Dashboard',
      bullets: [
        '4 tarjetas de estado en tiempo real',
        'Gráficos de recursos y ancho de banda',
        'Últimos eventos del sistema',
      ],
      accentColor: AppColors.primary,
      tabIndex: 1,
    ),
    _SummaryCardData(
      miniature: const ServicesMiniature(),
      name: 'Servicios',
      bullets: [
        'Estado de Passbolt y ChkMonitor',
        'Infraestructura Docker',
        '2 vistas: Servicios y Bases de datos',
      ],
      accentColor: AppColors.secondary,
      tabIndex: 2,
    ),
    _SummaryCardData(
      miniature: const MetricsMiniature(),
      name: 'Métricas',
      bullets: [
        'Histórico por rango (1h / 6h / 24h / 7d)',
        'CPU, RAM, Disco, Latencia SNMP',
        'Timeline de uptime',
      ],
      accentColor: AppColors.chartCpu,
      tabIndex: 3,
    ),
    _SummaryCardData(
      miniature: const AlertsMiniature(),
      name: 'Alertas',
      bullets: [
        'Alertas activas por severidad',
        'Historial de incidentes',
        'Umbrales configurados',
      ],
      accentColor: AppColors.warning,
      tabIndex: 4,
    ),
    _SummaryCardData(
      miniature: const UsersMiniature(),
      name: 'Usuarios',
      bullets: [
        'Lista de usuarios y roles',
        'Sesiones activas en tiempo real',
        'Log de accesos recientes',
      ],
      accentColor: AppColors.primaryBright,
      tabIndex: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (columns >= 5) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              child: _SummaryScreenCard(
                data: _cards[i],
                onTap: () => tabController.animateTo(_cards[i].tabIndex),
              ),
            ),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < _cards.length; i += columns) {
      final rowCards = _cards.skip(i).take(columns).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < columns; j++) ...[
              if (j > 0) const SizedBox(width: 16),
              Expanded(
                child: j < rowCards.length
                    ? _SummaryScreenCard(
                        data: rowCards[j],
                        onTap: () =>
                            tabController.animateTo(rowCards[j].tabIndex),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      if (i + columns < _cards.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.miniature,
    required this.name,
    required this.bullets,
    required this.accentColor,
    required this.tabIndex,
  });

  final Widget miniature;
  final String name;
  final List<String> bullets;
  final Color accentColor;
  final int tabIndex;
}

class _SummaryScreenCard extends StatelessWidget {
  const _SummaryScreenCard({required this.data, required this.onTap});

  final _SummaryCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 180 / 260,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: data.miniature,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final bullet in data.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '· ',
                      style: TextStyle(
                        color: data.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
