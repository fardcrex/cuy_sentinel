part of '../welcome_screen.dart';

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: AppColors.panel,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppAssets.logoHorizontalPrimary, height: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Sistema externo de monitoreo y verificación de actividad.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Servicios',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              const _FooterLink('Passbolt · 1161'),
                              const _FooterLink('ChkMonitor · 2161'),
                              const _FooterLink('SNMP v2c / v3'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Etapas',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              const _FooterLink('Etapa 1 ✓'),
                              const _FooterLink('Etapa 2 ⟳'),
                              const _FooterLink('Etapa 3 ⏳'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          AppAssets.logoHorizontalPrimary,
                          height: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sistema externo de monitoreo y\nverificación de actividad.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Servicios monitoreados',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 12),
                        const _FooterLink('Passbolt · puerto 1161'),
                        const _FooterLink('ChkMonitor · puerto 2161'),
                        const _FooterLink('SNMP v2c / v3'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Etapas',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 12),
                        const _FooterLink('Etapa 1 · Infraestructura ✓'),
                        const _FooterLink('Etapa 2 · Sistema web ⟳'),
                        const _FooterLink('Etapa 3 · Concurrencia ⏳'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(color: AppColors.stroke),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Programación de Interfaces y Dispositivos Periféricos',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textInactive),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Prof. Rene Alejandro Zamudio Ariza',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textInactive,
                      ),
                    ),
                  ),
                  Text(
                    '© 2025 Cuy Sentinel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textInactive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}
