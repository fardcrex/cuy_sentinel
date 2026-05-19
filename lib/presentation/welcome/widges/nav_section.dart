part of '../welcome_page.dart';

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
        onTeam: () {
          Navigator.pop(ctx);
          onTeam();
        },
        onEtapa: () {
          Navigator.pop(ctx);
          onEtapa();
        },
        onArch: () {
          Navigator.pop(ctx);
          onArch();
        },
        onPlatforms: () {
          Navigator.pop(ctx);
          onPlatforms();
        },
        onTech: () {
          Navigator.pop(ctx);
          onTech();
        },
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
