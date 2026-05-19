part of '../welcome_page.dart';

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background.withValues(alpha: 0.9),
            AppColors.panel.withValues(alpha: 0.2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= AppBreakpoints.mobile;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(flex: 5, child: _HeroContent()),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 460),
                        child: Image.asset(
                          AppAssets.illustrationMonitoringGuard,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  const _HeroContent(),
                  const SizedBox(height: 40),
                  Image.asset(
                    AppAssets.illustrationMonitoringGuard,
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.tealGlow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Programación de Interfaces y Dispositivos Periféricos',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.mainBrandGradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Cuy Sentinel',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sistema externo de monitoreo SNMP\npara infraestructura dockerizada',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progreso del proyecto',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  _EtapaChip(
                    label: 'Etapa 1',
                    sublabel: 'Infraestructura',
                    done: true,
                  ),
                  _EtapaDivider(active: true),
                  _EtapaChip(
                    label: 'Etapa 2',
                    sublabel: 'Sistema web',
                    active: true,
                  ),
                  _EtapaDivider(active: false),
                  _EtapaChip(
                    label: 'Etapa 3',
                    sublabel: 'Análisis y sustentación',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EtapaChip extends StatelessWidget {
  const _EtapaChip({
    required this.label,
    required this.sublabel,
    this.done = false,
    this.active = false,
  });

  final String label;
  final String sublabel;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color accent = done
        ? AppColors.primary
        : active
        ? AppColors.warning
        : AppColors.textInactive;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accent.withValues(alpha: active || done ? 0.5 : 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (done)
                  Icon(Icons.check_circle_rounded, size: 12, color: accent)
                else if (active)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(Icons.schedule_rounded, size: 12, color: accent),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EtapaDivider extends StatelessWidget {
  const _EtapaDivider({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: SizedBox(
        width: 20,
        child: Divider(
          color: active
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.stroke,
          thickness: 1.5,
        ),
      ),
    );
  }
}
