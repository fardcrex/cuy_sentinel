import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brand_asset_icon.dart';
import '../widgets/matrix_background.dart';

const double _kContentMaxWidth = 1280.0;

// ─── Screen ───────────────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _teamKey = GlobalKey();
  final _etapaKey = GlobalKey();
  final _archKey = GlobalKey();
  final _platformsKey = GlobalKey();
  final _techKey = GlobalKey();

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (_, _) => CustomPaint(
                  painter: MatrixBackgroundPainter(
                    progress: _bgController.value,
                    density: 0.35,
                    toneColor: AppColors.primary,
                    accentToneColor: AppColors.primaryBright,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _NavBar(
                  onTeam: () => _scrollTo(_teamKey),
                  onEtapa: () => _scrollTo(_etapaKey),
                  onArch: () => _scrollTo(_archKey),
                  onPlatforms: () => _scrollTo(_platformsKey),
                  onTech: () => _scrollTo(_techKey),
                ),
                _HeroSection(onViewArch: () => _scrollTo(_archKey)),
                _TeamSection(sectionKey: _teamKey),
                _EtapaObjectivesSection(sectionKey: _etapaKey),
                _Phase1Section(sectionKey: _archKey),
                const _Phase2Section(),
                _PlatformsSection(sectionKey: _platformsKey),
                _TechStackSection(sectionKey: _techKey),
                const _FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navbar ───────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.onTeam,
    required this.onEtapa,
    required this.onArch,
    required this.onPlatforms,
    required this.onTech,
  });

  final VoidCallback onTeam;
  final VoidCallback onEtapa;
  final VoidCallback onArch;
  final VoidCallback onPlatforms;
  final VoidCallback onTech;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: AppColors.stroke)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: Row(
            children: [
              Image.asset(AppAssets.logoHorizontalPrimary, height: 36),
              const Spacer(),
              _NavPill(label: 'Equipo', onTap: onTeam),
              const SizedBox(width: 2),
              _NavPill(label: 'Objetivos', onTap: onEtapa),
              const SizedBox(width: 2),
              _NavPill(label: 'Arquitectura', onTap: onArch),
              const SizedBox(width: 2),
              _NavPill(label: 'Plataformas', onTap: onPlatforms),
              const SizedBox(width: 2),
              _NavPill(label: 'Tecnologías', onTap: onTech),
              const SizedBox(width: 16),
              Builder(
                builder: (context) => DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppColors.successGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.background,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.lock_open_rounded, size: 16),
                    label: const Text('Acceder al panel'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onViewArch});

  final VoidCallback onViewArch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background,
            AppColors.panel.withValues(alpha: 0.8),
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
              final isWide = constraints.maxWidth >= AppBreakpoints.tablet;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _HeroContent(onViewArch: onViewArch),
                    ),
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
                  _HeroContent(onViewArch: onViewArch),
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
  const _HeroContent({required this.onViewArch});

  final VoidCallback onViewArch;

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
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
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
              Text(
                'Programación de Interfaces y Dispositivos Periféricos',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
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
        const SizedBox(height: 20),
        Text(
          'Monitoreamos Passbolt y ChkMonitor vía SNMP, almacenamos métricas en '
          'base de datos redundante y visualizamos el estado de la infraestructura '
          'en tiempo real desde cualquier dispositivo.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 32),
        Builder(
          builder: (context) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AppColors.successGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.background,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 20,
                  ),
                  label: const Text('Entrar al panel'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onViewArch,
                icon: const Icon(Icons.account_tree_outlined, size: 18),
                label: const Text('Ver arquitectura'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HeroBadge(asset: AppAssets.badgeSnmpSuccess, label: 'SNMP v2c/v3'),
            _HeroBadge(
              asset: AppAssets.badgePassboltSuccess,
              label: 'Passbolt :1161',
            ),
            _HeroBadge(
              asset: AppAssets.badgeServerSuccess,
              label: 'ChkMonitor :2161',
            ),
            _HeroBadge(
              asset: AppAssets.badgeBdSuccess,
              label: 'BD Redundante',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, width: 20, height: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section wrapper ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    this.sectionKey,
    required this.color,
    required this.child,
  });

  final GlobalKey? sectionKey;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      decoration: BoxDecoration(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: child,
        ),
      ),
    );
  }
}

// ─── Team ─────────────────────────────────────────────────────────────────────

class _TeamSection extends StatelessWidget {
  const _TeamSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _members = [
    _Member(
      name: 'Jair Conislla Bocangel',
      role: 'Desarrollador Full-Stack',
      initials: 'JC',
      asset: AppAssets.teamJair,
    ),
    _Member(
      name: 'Daniel Rojas Sanchez',
      role: 'Desarrollador Full-Stack',
      initials: 'DR',
      asset: AppAssets.teamDaniel,
    ),
    _Member(
      name: 'Jheampierre Ralli Peralta',
      role: 'Desarrollador Full-Stack',
      initials: 'JR',
      asset: AppAssets.teamJheampierre,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.panel,
      child: Column(
        children: [
          const _SectionLabel(label: 'EQUIPO'),
          const SizedBox(height: 12),
          Text(
            'Los que lo construyeron',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Programación de Interfaces y Dispositivos Periféricos · Prof. Rene A. Zamudio Ariza',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _members
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 240,
                            child: _MemberCard(member: m),
                          ),
                        ),
                      )
                      .toList(),
                );
              }
              return Column(
                children: _members
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _MemberCard(member: m),
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

class _Member {
  const _Member({
    required this.name,
    required this.role,
    required this.initials,
    required this.asset,
  });

  final String name;
  final String role;
  final String initials;
  final String asset;
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _Avatar(asset: member.asset, initials: member.initials),
          const SizedBox(height: 16),
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.tealGlow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              member.role,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.asset, required this.initials});

  final String asset;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        asset,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, e, s) => Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            gradient: AppColors.mainBrandGradient,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Etapa 2 Objectives ───────────────────────────────────────────────────────

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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desarrollo del sistema web y almacenamiento de métricas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
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

// ─── Phase 1 ─────────────────────────────────────────────────────────────────

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
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
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

// ─── Phase 2 ─────────────────────────────────────────────────────────────────

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
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
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

// Phase shared widgets ─────────────────────────────────────────────────────────

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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
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

// ─── Platforms ────────────────────────────────────────────────────────────────

enum _DeviceType { phone, tablet, laptop, desktop }

class _PlatformsSection extends StatelessWidget {
  const _PlatformsSection({required this.sectionKey});

  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.panel,
      child: Column(
        children: [
          const _SectionLabel(label: 'MULTIPLATAFORMA'),
          const SizedBox(height: 12),
          Text(
            'Disponible en todos los dispositivos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Un único codebase Flutter compilado nativamente para cada plataforma',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 56),
          Wrap(
            spacing: 48,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: const [
              _DeviceShowcase(
                type: _DeviceType.phone,
                label: 'Smartphone',
                platforms: 'iOS · Android',
              ),
              _DeviceShowcase(
                type: _DeviceType.tablet,
                label: 'Tablet',
                platforms: 'iPad · Android',
              ),
              _DeviceShowcase(
                type: _DeviceType.laptop,
                label: 'Laptop',
                platforms: 'macOS · Windows',
              ),
              _DeviceShowcase(
                type: _DeviceType.desktop,
                label: 'Escritorio / Web',
                platforms: 'Browser · Desktop',
              ),
            ],
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.tealGlow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flutter_dash_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Flutter — un codebase, infinitas plataformas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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

class _DeviceShowcase extends StatelessWidget {
  const _DeviceShowcase({
    required this.type,
    required this.label,
    required this.platforms,
  });

  final _DeviceType type;
  final String label;
  final String platforms;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 130,
          child: CustomPaint(painter: _DevicePainter(type)),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          platforms,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DevicePainter extends CustomPainter {
  const _DevicePainter(this.type);

  final _DeviceType type;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyFill = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    final bodyStroke = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final screenFill = Paint()
      ..color = AppColors.tealGlow
      ..style = PaintingStyle.fill;
    final lineHint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final accentFill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    switch (type) {
      case _DeviceType.phone:
        _drawPhone(canvas, size, bodyFill, bodyStroke, screenFill, lineHint, accentFill);
      case _DeviceType.tablet:
        _drawTablet(canvas, size, bodyFill, bodyStroke, screenFill, lineHint, accentFill);
      case _DeviceType.laptop:
        _drawLaptop(canvas, size, bodyFill, bodyStroke, screenFill, lineHint);
      case _DeviceType.desktop:
        _drawDesktop(canvas, size, bodyFill, bodyStroke, screenFill, lineHint);
    }
  }

  void _drawPhone(
    Canvas c, Size s,
    Paint bf, Paint bs, Paint sf, Paint lh, Paint af,
  ) {
    final cx = s.width / 2;
    final cy = s.height / 2 - 4;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 52, height: 96),
      const Radius.circular(12),
    );
    c.drawRRect(body, bf);
    c.drawRRect(body, bs);
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 44, height: 76),
      const Radius.circular(5),
    );
    c.drawRRect(screen, sf);
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 42), width: 10, height: 4),
      af,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 44), width: 18, height: 3),
        const Radius.circular(2),
      ),
      af,
    );
    for (var i = 0; i < 3; i++) {
      final y = cy - 18 + i * 14.0;
      c.drawLine(Offset(cx - 14, y), Offset(cx + (i == 1 ? 6 : 14), y), lh);
    }
  }

  void _drawTablet(
    Canvas c, Size s,
    Paint bf, Paint bs, Paint sf, Paint lh, Paint af,
  ) {
    final cx = s.width / 2;
    final cy = s.height / 2 - 2;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 76, height: 96),
      const Radius.circular(10),
    );
    c.drawRRect(body, bf);
    c.drawRRect(body, bs);
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 66, height: 84),
      const Radius.circular(4),
    );
    c.drawRRect(screen, sf);
    c.drawCircle(Offset(cx, cy - 43), 3, af);
    for (var i = 0; i < 4; i++) {
      final y = cy - 22 + i * 13.0;
      c.drawLine(
        Offset(cx - 24, y),
        Offset(cx + (i % 2 == 0 ? 24 : 14), y),
        lh,
      );
    }
  }

  void _drawLaptop(
    Canvas c, Size s,
    Paint bf, Paint bs, Paint sf, Paint lh,
  ) {
    final cx = s.width / 2;
    final screenFrame = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 52, 4, 104, 68),
      const Radius.circular(5),
    );
    c.drawRRect(screenFrame, bf);
    c.drawRRect(screenFrame, bs);
    final screenInner = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 47, 8, 94, 60),
      const Radius.circular(3),
    );
    c.drawRRect(screenInner, sf);
    c.drawCircle(
      Offset(cx, 7),
      2,
      Paint()..color = AppColors.primary.withValues(alpha: 0.4)..style = PaintingStyle.fill,
    );
    c.drawRect(Rect.fromLTWH(cx - 57, 72, 114, 4), bf);
    c.drawRect(Rect.fromLTWH(cx - 57, 72, 114, 4), bs);
    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 58, 76, 116, 20),
      const Radius.circular(3),
    );
    c.drawRRect(base, bf);
    c.drawRRect(base, bs);
    final keyPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 5; col++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 44 + col * 18.0, 80 + row * 7.0, 13, 4),
            const Radius.circular(1),
          ),
          keyPaint,
        );
      }
    }
    for (var i = 0; i < 3; i++) {
      final y = 20.0 + i * 13.0;
      c.drawLine(Offset(cx - 34, y), Offset(cx + (i == 1 ? 18 : 34), y), lh);
    }
  }

  void _drawDesktop(
    Canvas c, Size s,
    Paint bf, Paint bs, Paint sf, Paint lh,
  ) {
    final cx = s.width / 2;
    final monitor = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 52, 2, 104, 70),
      const Radius.circular(5),
    );
    c.drawRRect(monitor, bf);
    c.drawRRect(monitor, bs);
    final screen = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 47, 6, 94, 62),
      const Radius.circular(3),
    );
    c.drawRRect(screen, sf);
    c.drawRect(Rect.fromLTWH(cx - 4, 72, 8, 18), bf);
    c.drawRect(Rect.fromLTWH(cx - 4, 72, 8, 18), bs);
    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 28, 90, 56, 10),
      const Radius.circular(5),
    );
    c.drawRRect(base, bf);
    c.drawRRect(base, bs);
    for (var i = 0; i < 4; i++) {
      final y = 18.0 + i * 12.0;
      c.drawLine(
        Offset(cx - 36, y),
        Offset(cx + (i % 2 == 0 ? 36 : 22), y),
        lh,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DevicePainter old) => old.type != type;
}

// ─── Tech Stack ───────────────────────────────────────────────────────────────

class _TechStackSection extends StatelessWidget {
  const _TechStackSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _stack = [
    _TechData(
      name: 'Flutter',
      icon: Icons.flutter_dash_rounded,
      color: AppColors.secondary,
      why:
          'Panel multiplataforma desde un único codebase. Compila nativamente a iOS, Android, Web y Desktop con alto rendimiento.',
    ),
    _TechData(
      name: 'Go',
      icon: Icons.memory_rounded,
      color: AppColors.primary,
      why:
          'Concurrencia nativa con goroutines, ideal para recolección SNMP periódica y manejo paralelo de múltiples servicios.',
    ),
    _TechData(
      name: 'Supabase',
      icon: Icons.bolt_rounded,
      color: AppColors.primaryBright,
      why:
          'Plataforma BaaS que provee PostgreSQL, Auth, Realtime y Storage sin necesidad de gestionar infraestructura en Fase 1.',
    ),
    _TechData(
      name: 'PostgreSQL',
      icon: Icons.storage_rounded,
      color: AppColors.secondary,
      why:
          'BD relacional robusta con réplica asíncrona Streaming/WAL. Soporta alta disponibilidad y escalabilidad de lectura en Fase 2.',
    ),
    _TechData(
      name: 'Node.js + Socket.IO',
      icon: Icons.hub_outlined,
      color: AppColors.primaryBright,
      why:
          'API REST desacoplada para Fase 2. Socket.IO permite eventos en tiempo real sin polling, reduciendo latencia en el panel.',
    ),
    _TechData(
      name: 'Ubuntu 24.04 LTS',
      icon: Icons.computer_rounded,
      color: AppColors.warning,
      why:
          'Sistema operativo de despliegue con soporte extendido hasta 2029. Estabilidad comprobada para dockerización de servicios críticos.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.background,
      child: Column(
        children: [
          const _SectionLabel(label: 'TECNOLOGÍAS'),
          const SizedBox(height: 12),
          Text(
            'Stack moderno de extremo a extremo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada herramienta elegida por una razón específica',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 600
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 300,
                ),
                itemCount: _stack.length,
                itemBuilder: (_, i) => _TechCard(tech: _stack[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TechData {
  const _TechData({
    required this.name,
    required this.icon,
    required this.color,
    required this.why,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String why;
}

class _TechCard extends StatelessWidget {
  const _TechCard({required this.tech});

  final _TechData tech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: tech.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tech.color.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: tech.color.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: Icon(tech.icon, size: 52, color: tech.color)),
          ),
          const SizedBox(height: 16),
          Text(
            tech.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tech.why,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: AppColors.panel,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppAssets.logoHorizontalPrimary, height: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Sistema externo de monitoreo y\nverificación de actividad.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
          ),
          const SizedBox(height: 40),
          const Divider(color: AppColors.stroke),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Programación de Interfaces y Dispositivos Periféricos · Prof. Rene Alejandro Zamudio Ariza',
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tealGlow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
