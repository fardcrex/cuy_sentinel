part of '../welcome_page.dart';

class _EtapaObjectivesSection extends StatelessWidget {
  const _EtapaObjectivesSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _objectives = [
    _Objective(
      number: '01',
      icon: AppAssets.iconChipMetrics,
      title: 'Recolección SNMP periódica',
      description:
          'Go consulta Passbolt (:1161) y ChkMonitor (:2161) cada 5-10 min vía SNMP con procesamiento, normalización y manejo automático de reintentos.',
      color: AppColors.primary,
    ),
    _Objective(
      number: '02',
      icon: AppAssets.iconDatabaseSync,
      title: 'Almacenamiento redundante',
      description:
          'Las métricas se persisten en base de datos con réplica asíncrona Streaming/WAL para garantizar disponibilidad ante fallas del nodo primario.',
      color: AppColors.secondary,
    ),
    _Objective(
      number: '03',
      icon: AppAssets.iconDashboardMonitor,
      title: 'Panel web con gráficas',
      description:
          'Visualización interactiva de uso de RAM, disco y ancho de banda en tiempo real. Estado actual activo/inactivo de Passbolt y ChkMonitor.',
      color: AppColors.primaryBright,
    ),
    _Objective(
      number: '04',
      icon: AppAssets.iconAlertShield,
      title: 'Autenticación de acceso',
      description:
          'Acceso al panel mediante autenticación básica segura. Control de sesiones para administradores del sistema de monitoreo.',
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.background,
      child: Column(
        children: [
          const _SectionLabel(label: 'ETAPA 2'),
          const SizedBox(height: 12),
          Text(
            '¿Qué estamos construyendo?',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Desarrollo del sistema web y almacenamiento de métricas',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              if (isWide) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ObjectiveCard(objective: _objectives[0]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ObjectiveCard(objective: _objectives[1]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ObjectiveCard(objective: _objectives[2]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ObjectiveCard(objective: _objectives[3]),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Column(
                children: _objectives
                    .map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ObjectiveCard(objective: o),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Objective {
  const _Objective({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final String number;
  final String icon;
  final String title;
  final String description;
  final Color color;
}

class _ObjectiveCard extends StatelessWidget {
  const _ObjectiveCard({required this.objective});

  final _Objective objective;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: objective.color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: objective.color.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                objective.number,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: objective.color.withValues(alpha: 0.18),
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),
              BrandAssetIcon(
                assetPath: objective.icon,
                size: 100,
                padding: const EdgeInsets.all(14),
                backgroundColor: objective.color.withValues(alpha: 0.1),
                borderColor: objective.color.withValues(alpha: 0.25),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  objective.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  objective.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
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
