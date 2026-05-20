part of '../welcome_page.dart';

class _ProfessorSection extends StatelessWidget {
  const _ProfessorSection();

  static const _profe = _Member(
    name: 'Rene Alejandro Zamudio Ariza',
    role: 'Docente del Curso',
    initials: 'RZ',
    roleColor: AppColors.warning,
  );

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: AppColors.background,
      child: Column(
        children: [
          const _SectionLabel(label: 'MENTORÍA & LIDERAZGO'),
          const SizedBox(height: 50),
          const SizedBox(width: 260, child: _MemberCard(member: _profe)),
          const SizedBox(height: 60),
          Text(
            'El pilar académico del curso',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Su enfoque práctico y exigente nos llevó a construir algo más que un trabajo universitario',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: AppColors.warning,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'El Prof. Zamudio nos enseñó que monitorear infraestructura no es solo capturar datos — es entender cada capa del sistema. Esa visión guió cada decisión de arquitectura en Cuy Sentinel.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.65,
                        fontStyle: FontStyle.italic,
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

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _services = [
    _ServiceItem(
      asset: AppAssets.badgeSnmpSuccess,
      name: 'SNMP v2c / v3',
      description:
          'Protocolo de monitoreo de red para recolección periódica de métricas.',
    ),
    _ServiceItem(
      asset: AppAssets.badgePassboltSuccess,
      name: 'Passbolt',
      description:
          'Gestor de contraseñas dockerizado. Monitoreado en el puerto :1161.',
    ),
    _ServiceItem(
      asset: AppAssets.badgeServerSuccess,
      name: 'ChkMonitor',
      description:
          'Servicio de verificación de actividad expuesto en el puerto :2161.',
    ),
    _ServiceItem(
      asset: AppAssets.badgeBdSuccess,
      name: 'BD Redundante',
      description:
          'Réplica asíncrona vía Streaming/WAL para alta disponibilidad.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.panel,
      child: Column(
        children: [
          const _SectionLabel(label: 'INFRAESTRUCTURA'),
          const SizedBox(height: 12),
          Text(
            'Servicios monitoreados',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Acceso remoto vía SNMP a los servicios dockerizados de la institución',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 56),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _services
                      .map(
                        (service) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _ServiceCard(service: service),
                          ),
                        ),
                      )
                      .toList(),
                );
              }
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _services
                    .map(
                      (service) => SizedBox(
                        width: 200,
                        child: _ServiceCard(service: service),
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

class _ServiceItem {
  const _ServiceItem({
    required this.asset,
    required this.name,
    required this.description,
  });

  final String asset;
  final String name;
  final String description;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final _ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            service.asset,
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            service.name,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
