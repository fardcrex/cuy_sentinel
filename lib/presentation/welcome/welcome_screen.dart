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
  final _servicesKey = GlobalKey();
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
                    density: 0.8,
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
                const _HeroSection(),
                _TeamSection(sectionKey: _teamKey),
                const _ProfessorSection(),
                _ServicesSection(sectionKey: _servicesKey),
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

  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _NavBottomSheet(
        onTeam: () { Navigator.pop(ctx); onTeam(); },
        onEtapa: () { Navigator.pop(ctx); onEtapa(); },
        onArch: () { Navigator.pop(ctx); onArch(); },
        onPlatforms: () { Navigator.pop(ctx); onPlatforms(); },
        onTech: () { Navigator.pop(ctx); onTech(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.panel.withValues(alpha: 0.92),
          border: const Border(bottom: BorderSide(color: AppColors.stroke)),
        ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              if (isMobile) {
                return Row(
                  children: [
                    Image.asset(AppAssets.logoMarkShield, height: 32),
                    const Spacer(),
                    Builder(
                      builder: (ctx) => FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => ctx.go(AppRoutes.login),
                        icon: const Icon(Icons.lock_open_rounded, size: 15),
                        label: const Text('Acceder'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Menú',
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => _openMenu(context),
                    ),
                  ],
                );
              }

              return Row(
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
                    builder: (ctx) => DecoratedBox(
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
                          textStyle: Theme.of(ctx).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        onPressed: () => ctx.go(AppRoutes.login),
                        icon: const Icon(Icons.lock_open_rounded, size: 16),
                        label: const Text('Acceder al panel'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
  }
}

class _NavBottomSheet extends StatelessWidget {
  const _NavBottomSheet({
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _NavSheetItem(
            icon: Icons.people_outline_rounded,
            label: 'Equipo',
            onTap: onTeam,
          ),
          _NavSheetItem(
            icon: Icons.flag_outlined,
            label: 'Objetivos',
            onTap: onEtapa,
          ),
          _NavSheetItem(
            icon: Icons.account_tree_outlined,
            label: 'Arquitectura',
            onTap: onArch,
          ),
          _NavSheetItem(
            icon: Icons.devices_rounded,
            label: 'Plataformas',
            onTap: onPlatforms,
          ),
          _NavSheetItem(
            icon: Icons.layers_outlined,
            label: 'Tecnologías',
            onTap: onTech,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.stroke),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (ctx) => FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => ctx.go(AppRoutes.login),
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text(
                  'Acceder al panel',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSheetItem extends StatelessWidget {
  const _NavSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textInactive,
      ),
      onTap: onTap,
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
        // Etapa 2 progress card
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
              Row(
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
                    done: false,
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

// ─── Section wrapper ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({this.sectionKey, required this.color, required this.child});

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
            'Fundadores',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'El equipo detrás de Cuy Sentinel',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
    this.roleColor = AppColors.primary,
  });

  final String name;
  final String role;
  final String initials;
  final String asset;
  final Color roleColor;
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
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _Avatar(asset: member.asset, initials: member.initials),
          const SizedBox(height: 16),
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: member.roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              member.role,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: member.roleColor,
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Un único codebase Flutter compilado nativamente para cada plataforma',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
                Flexible(
                  child: Text(
                    'Flutter — un codebase, infinitas plataformas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
    final isWide =
        type == _DeviceType.laptop || type == _DeviceType.desktop;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isWide ? 160 : 130,
          height: 148,
          child: CustomPaint(painter: _DevicePainter(type)),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          platforms,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _DevicePainter extends CustomPainter {
  const _DevicePainter(this.type);

  final _DeviceType type;

  Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _stroke(Color c, [double w = 0.8]) =>
      Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w;
  RRect _rr(Rect r, [double radius = 2.5]) =>
      RRect.fromRectAndRadius(r, Radius.circular(radius));

  // Miniature metric card
  void _card(Canvas c, double x, double y, double w, double h, Color accent) {
    c.drawRRect(_rr(Rect.fromLTWH(x, y, w, h), 2), _fill(AppColors.surface));
    c.drawRRect(
      _rr(Rect.fromLTWH(x, y, w, h), 2),
      _stroke(AppColors.stroke, 0.4),
    );
    // left accent bar
    c.drawRRect(
      _rr(Rect.fromLTWH(x, y, 2, h), 1),
      _fill(accent.withValues(alpha: 0.8)),
    );
    // value line
    c.drawRRect(
      _rr(Rect.fromLTWH(x + 5, y + 2.5, w * 0.45, 2), 1),
      _fill(accent.withValues(alpha: 0.6)),
    );
    // label line
    c.drawRRect(
      _rr(Rect.fromLTWH(x + 5, y + 6.5, w * 0.3, 1.5), 1),
      _fill(AppColors.textInactive.withValues(alpha: 0.35)),
    );
  }

  // Header bar
  void _header(Canvas c, Rect screen, double h) {
    c.drawRect(
      Rect.fromLTWH(screen.left, screen.top, screen.width, h),
      _fill(AppColors.panel),
    );
    // bottom border with teal tint
    c.drawLine(
      Offset(screen.left, screen.top + h),
      Offset(screen.right, screen.top + h),
      _stroke(AppColors.primary.withValues(alpha: 0.3), 0.5),
    );
    // logo dot
    c.drawCircle(
      Offset(screen.left + 5, screen.top + h / 2),
      2,
      _fill(AppColors.primary.withValues(alpha: 0.85)),
    );
  }

  // Sidebar navigation
  void _sidebar(Canvas c, Rect screen, double w) {
    c.drawRect(
      Rect.fromLTWH(screen.left, screen.top, w, screen.height),
      _fill(AppColors.panel),
    );
    c.drawLine(
      Offset(screen.left + w, screen.top),
      Offset(screen.left + w, screen.bottom),
      _stroke(AppColors.stroke, 0.4),
    );
    // nav items
    for (var i = 0; i < 4; i++) {
      final y = screen.top + 14 + i * 9.0;
      if (i == 0) {
        c.drawRRect(
          _rr(Rect.fromLTWH(screen.left + 2, y - 1, w - 4, 7), 2),
          _fill(AppColors.primary.withValues(alpha: 0.18)),
        );
      }
      c.drawRRect(
        _rr(Rect.fromLTWH(screen.left + 4, y + 1, w - 10, 3), 1),
        _fill(
          (i == 0 ? AppColors.primary : AppColors.textInactive)
              .withValues(alpha: i == 0 ? 0.6 : 0.22),
        ),
      );
    }
  }

  // Bottom navigation bar (phone)
  void _bottomNav(Canvas c, Rect screen, int count) {
    const h = 10.0;
    c.drawRect(
      Rect.fromLTWH(screen.left, screen.bottom - h, screen.width, h),
      _fill(AppColors.panel),
    );
    c.drawLine(
      Offset(screen.left, screen.bottom - h),
      Offset(screen.right, screen.bottom - h),
      _stroke(AppColors.stroke, 0.4),
    );
    final spacing = screen.width / count;
    for (var i = 0; i < count; i++) {
      final x = screen.left + spacing * i + spacing / 2;
      c.drawCircle(
        Offset(x, screen.bottom - h / 2),
        2,
        _fill(
          i == 0
              ? AppColors.primary.withValues(alpha: 0.9)
              : AppColors.textInactive.withValues(alpha: 0.3),
        ),
      );
    }
  }

  // Mini bar chart
  void _chart(Canvas c, Rect area) {
    c.drawRRect(_rr(area, 2), _fill(AppColors.surface));
    c.drawRRect(_rr(area, 2), _stroke(AppColors.stroke, 0.4));
    final colors = [
      AppColors.primary,
      AppColors.primaryBright,
      AppColors.primary,
      AppColors.secondary,
      AppColors.primaryBright,
      AppColors.primary,
    ];
    final bw = (area.width - 6) / colors.length;
    for (var i = 0; i < colors.length; i++) {
      final bh = 2.5 + (i % 3) * 2.5;
      c.drawRRect(
        _rr(
          Rect.fromLTWH(
            area.left + 3 + i * (bw + 0.5),
            area.bottom - 3 - bh,
            bw,
            bh,
          ),
          1,
        ),
        _fill(colors[i].withValues(alpha: 0.65)),
      );
    }
  }

  // Status chip row
  void _statusRow(Canvas c, double x, double y, double w, int count) {
    final chipW = (w - (count - 1) * 2) / count;
    for (var i = 0; i < count; i++) {
      final cx = x + i * (chipW + 2);
      c.drawRRect(
        _rr(Rect.fromLTWH(cx, y, chipW, 6), 2),
        _fill(AppColors.tealGlow),
      );
      c.drawCircle(
        Offset(cx + 4, y + 3),
        1.5,
        _fill(AppColors.primary.withValues(alpha: 0.8)),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _DeviceType.phone:
        _drawPhone(canvas, size);
      case _DeviceType.tablet:
        _drawTablet(canvas, size);
      case _DeviceType.laptop:
        _drawLaptop(canvas, size);
      case _DeviceType.desktop:
        _drawDesktop(canvas, size);
    }
  }

  void _drawPhone(Canvas c, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2 - 2;
    // Body
    c.drawRRect(
      _rr(Rect.fromCenter(center: Offset(cx, cy), width: 56, height: 104), 13),
      _fill(AppColors.surface),
    );
    c.drawRRect(
      _rr(Rect.fromCenter(center: Offset(cx, cy), width: 56, height: 104), 13),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    // Screen
    final screen = Rect.fromCenter(
      center: Offset(cx, cy - 1),
      width: 48,
      height: 88,
    );
    c.drawRRect(_rr(screen, 6), _fill(AppColors.background));
    // Notch
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx, screen.top + 3),
        width: 10,
        height: 4,
      ),
      _fill(AppColors.primary.withValues(alpha: 0.4)),
    );
    // Header
    _header(c, screen, 9);
    // 2×2 cards
    final cw = (screen.width - 5) / 2;
    final ch = 13.0;
    final cardColors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.secondary,
      AppColors.primaryBright,
    ];
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        _card(
          c,
          screen.left + 1 + col * (cw + 2),
          screen.top + 11 + row * (ch + 3),
          cw,
          ch,
          cardColors[row * 2 + col],
        );
      }
    }
    // Status chips
    _statusRow(
      c,
      screen.left + 1,
      screen.top + 11 + 2 * (ch + 3) + 2,
      screen.width - 2,
      2,
    );
    // Bottom nav
    _bottomNav(c, screen, 4);
    // Home bar
    c.drawRRect(
      _rr(
        Rect.fromCenter(center: Offset(cx, cy + 50), width: 18, height: 3),
        2,
      ),
      _fill(AppColors.primary.withValues(alpha: 0.35)),
    );
  }

  void _drawTablet(Canvas c, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2 - 2;
    // Body
    c.drawRRect(
      _rr(Rect.fromCenter(center: Offset(cx, cy), width: 84, height: 104), 10),
      _fill(AppColors.surface),
    );
    c.drawRRect(
      _rr(Rect.fromCenter(center: Offset(cx, cy), width: 84, height: 104), 10),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    // Screen
    final screen = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 74,
      height: 92,
    );
    c.drawRRect(_rr(screen, 4), _fill(AppColors.background));
    // Camera
    c.drawCircle(
      Offset(cx, screen.top - 5),
      2.5,
      _fill(AppColors.primary.withValues(alpha: 0.35)),
    );
    // Narrow rail sidebar
    _sidebar(c, screen, 16);
    final content = Rect.fromLTRB(
      screen.left + 16,
      screen.top,
      screen.right,
      screen.bottom,
    );
    // Header in content area
    _header(c, content, 9);
    // 2×2 cards
    final cw = (content.width - 5) / 2;
    final ch = 15.0;
    final cardColors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.secondary,
      AppColors.primaryBright,
    ];
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        _card(
          c,
          content.left + 1 + col * (cw + 2),
          content.top + 11 + row * (ch + 3),
          cw,
          ch,
          cardColors[row * 2 + col],
        );
      }
    }
    // Status row
    _statusRow(
      c,
      content.left + 1,
      content.top + 11 + 2 * (ch + 3) + 2,
      content.width - 2,
      2,
    );
  }

  void _drawLaptop(Canvas c, Size s) {
    final cx = s.width / 2;
    // Frame
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 58, 4, 116, 74), 5),
      _fill(AppColors.surface),
    );
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 58, 4, 116, 74), 5),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    // Screen inner
    final screen = Rect.fromLTWH(cx - 53, 8, 106, 66);
    c.drawRRect(_rr(screen, 3), _fill(AppColors.background));
    // Camera
    c.drawCircle(
      Offset(cx, 7),
      2,
      _fill(AppColors.primary.withValues(alpha: 0.35)),
    );
    // Sidebar
    _sidebar(c, screen, 20);
    final content = Rect.fromLTRB(
      screen.left + 20,
      screen.top,
      screen.right,
      screen.bottom,
    );
    // Header
    _header(c, content, 8);
    // 3 cards in a row
    final cw = (content.width - 8) / 3;
    final cardColors = [AppColors.primary, AppColors.warning, AppColors.secondary];
    for (var col = 0; col < 3; col++) {
      _card(
        c,
        content.left + 2 + col * (cw + 2),
        content.top + 11,
        cw,
        14,
        cardColors[col],
      );
    }
    // Chart
    _chart(
      c,
      Rect.fromLTWH(content.left + 2, content.top + 29, content.width - 4, 16),
    );
    // Status chips
    _statusRow(c, content.left + 2, content.top + 49, content.width - 4, 3);
    // Hinge
    c.drawRect(
      Rect.fromLTWH(cx - 63, 78, 126, 4),
      _fill(AppColors.surface),
    );
    c.drawRect(
      Rect.fromLTWH(cx - 63, 78, 126, 4),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
    // Base
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 64, 82, 128, 22), 3),
      _fill(AppColors.surface),
    );
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 64, 82, 128, 22), 3),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
    // Keys
    final kp = _fill(AppColors.primary.withValues(alpha: 0.14));
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 6; col++) {
        c.drawRRect(
          _rr(Rect.fromLTWH(cx - 50 + col * 17.0, 86 + row * 7.0, 13, 4), 1),
          kp,
        );
      }
    }
  }

  void _drawDesktop(Canvas c, Size s) {
    final cx = s.width / 2;
    // Monitor frame
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 58, 2, 116, 78), 5),
      _fill(AppColors.surface),
    );
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 58, 2, 116, 78), 5),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    // Screen
    final screen = Rect.fromLTWH(cx - 53, 6, 106, 70);
    c.drawRRect(_rr(screen, 3), _fill(AppColors.background));
    // Sidebar (wider on desktop)
    _sidebar(c, screen, 24);
    final content = Rect.fromLTRB(
      screen.left + 24,
      screen.top,
      screen.right,
      screen.bottom,
    );
    // Header
    _header(c, content, 8);
    // 3 cards
    final cw = (content.width - 8) / 3;
    final cardColors = [AppColors.primary, AppColors.warning, AppColors.secondary];
    for (var col = 0; col < 3; col++) {
      _card(
        c,
        content.left + 2 + col * (cw + 2),
        content.top + 11,
        cw,
        14,
        cardColors[col],
      );
    }
    // Chart
    _chart(
      c,
      Rect.fromLTWH(content.left + 2, content.top + 29, content.width - 4, 18),
    );
    // Status chips
    _statusRow(c, content.left + 2, content.top + 51, content.width - 4, 3);
    // Stand
    c.drawRect(
      Rect.fromLTWH(cx - 5, 80, 10, 20),
      _fill(AppColors.surface),
    );
    c.drawRect(
      Rect.fromLTWH(cx - 5, 80, 10, 20),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 30, 100, 60, 10), 5),
      _fill(AppColors.surface),
    );
    c.drawRRect(
      _rr(Rect.fromLTWH(cx - 30, 100, 60, 10), 5),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada herramienta elegida por una razón específica',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                        Image.asset(AppAssets.logoHorizontalPrimary, height: 36),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textInactive,
                ),
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

// ─── Professor ────────────────────────────────────────────────────────────────

class _ProfessorSection extends StatelessWidget {
  const _ProfessorSection();

  static const _profe = _Member(
    name: 'Rene Alejandro Zamudio Ariza',
    role: 'Docente del Curso',
    initials: 'RZ',
    asset: AppAssets.teamProfe,
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
          SizedBox(width: 260, child: _MemberCard(member: _profe)),
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

// ─── Services ─────────────────────────────────────────────────────────────────

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
                        (s) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _ServiceCard(service: s),
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
                      (s) =>
                          SizedBox(width: 200, child: _ServiceCard(service: s)),
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
