part of '../welcome_screen.dart';

class _Phase1Section extends StatelessWidget {
  const _Phase1Section({required this.sectionKey});

  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'ARQUITECTURA'),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '01',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.warning.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase 1 · Implementación Rápida',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flutter consume Supabase directamente. Go recolecta vía SNMP y escribe en BD cloud.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'En progreso',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(flex: 5, child: _Phase1Content()),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: Image.asset(
                          AppAssets.illustrationAnomalyDetected,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  const _Phase1Content(),
                  const SizedBox(height: 32),
                  Image.asset(
                    AppAssets.illustrationAnomalyDetected,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Phase1Content extends StatelessWidget {
  const _Phase1Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _FlowStep(
                icon: Icons.lock_outlined,
                title: 'Passbolt',
                subtitle: 'SNMP :1161',
                color: AppColors.warning,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.computer_rounded,
                title: 'ChkMonitor',
                subtitle: 'SNMP :2161',
                color: AppColors.warning,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.memory_rounded,
                title: 'Go',
                subtitle: 'Recolector',
                color: AppColors.primary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.bolt_rounded,
                title: 'Supabase',
                subtitle: 'Cloud BD',
                color: AppColors.primaryBright,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.flutter_dash_rounded,
                title: 'Flutter',
                subtitle: 'Panel Web',
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _PhaseComponent(
          color: AppColors.primary,
          title: 'Go Recolector',
          items: [
            'Consulta SNMP concurrente a ambos servicios',
            'Procesamiento y normalización de métricas',
            'Escritura directa en Supabase Cloud',
            'Reintento automático ante fallos de red',
            'Intervalo configurable de 5-10 minutos',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.primaryBright,
          title: 'Supabase Cloud',
          items: [
            'PostgreSQL como base de datos relacional',
            'Supabase Auth para autenticación de usuarios',
            'Realtime para suscripciones en tiempo real',
            'Storage para archivos y configuraciones',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.secondary,
          title: 'Flutter Panel',
          items: [
            'Consume Supabase REST + Realtime',
            'Dashboards y gráficas interactivas',
            'Multiplataforma: Android, iOS, Web, Desktop',
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Arquitectura simple y rápida de implementar. Go recolecta vía SNMP '
                  'y escribe directamente en Supabase. Flutter consume Supabase para '
                  'mostrar la información en tiempo real.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Phase2Section extends StatelessWidget {
  const _Phase2Section();

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'ARQUITECTURA'),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '02',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase 2 · Arquitectura Escalable',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Arquitectura desacoplada. Go escribe en PostgreSQL propio con réplica WAL. Node.js expone APIs y Socket.IO.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Planificado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 440),
                        child: Image.asset(
                          AppAssets.illustrationGuardianShield,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    const Expanded(flex: 5, child: _Phase2Content()),
                  ],
                );
              }
              return Column(
                children: [
                  const _Phase2Content(),
                  const SizedBox(height: 32),
                  Image.asset(
                    AppAssets.illustrationGuardianShield,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Phase2Content extends StatelessWidget {
  const _Phase2Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _FlowStep(
                icon: Icons.lock_outlined,
                title: 'Servicios',
                subtitle: ':1161 / :2161',
                color: AppColors.warning,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.memory_rounded,
                title: 'Go',
                subtitle: 'Recolector',
                color: AppColors.primary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.storage_rounded,
                title: 'PostgreSQL',
                subtitle: 'Primario + WAL',
                color: AppColors.secondary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.hub_outlined,
                title: 'Node.js',
                subtitle: 'API + Socket.IO',
                color: AppColors.primaryBright,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.flutter_dash_rounded,
                title: 'Flutter',
                subtitle: 'Panel Web',
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _PhaseComponent(
          color: AppColors.primary,
          title: 'Go Recolector',
          items: [
            'Consulta SNMP concurrente con goroutines',
            'Validación y procesamiento de métricas',
            'Escritura en PostgreSQL primario',
            'Reintentos y manejo de errores de red',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.secondary,
          title: 'PostgreSQL Alta Disponibilidad',
          items: [
            'BD primaria con escrituras del recolector',
            'Réplica asíncrona vía Streaming/WAL',
            'Alta disponibilidad y tolerancia a fallos',
            'Escalabilidad de lectura desde la réplica',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.primaryBright,
          title: 'Node.js + Socket.IO',
          items: [
            'APIs REST para el frontend Flutter',
            'Socket.IO para eventos en tiempo real',
            'Gestión de usuarios y autenticación',
            'Emite eventos al ingresar nuevas métricas',
          ],
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BenefitChip(
              label: 'Mayor escalabilidad',
              icon: Icons.trending_up_rounded,
              color: AppColors.primary,
            ),
            _BenefitChip(
              label: 'Alta disponibilidad',
              icon: Icons.verified_outlined,
              color: AppColors.secondary,
            ),
            _BenefitChip(
              label: 'Tiempo real eficiente',
              icon: Icons.bolt_rounded,
              color: AppColors.primaryBright,
            ),
            _BenefitChip(
              label: 'Separación de responsabilidades',
              icon: Icons.account_tree_outlined,
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Arquitectura desacoplada y escalable. PostgreSQL con réplica asegura '
                  'alta disponibilidad. Node.js expone APIs REST y eventos en tiempo real '
                  'vía Socket.IO. Flutter consume el API desacoplado.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: AppColors.primary.withValues(alpha: 0.5),
        size: 18,
      ),
    );
  }
}

class _PhaseComponent extends StatelessWidget {
  const _PhaseComponent({
    required this.color,
    required this.title,
    required this.items,
  });

  final Color color;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
