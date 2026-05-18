part of '../welcome_screen.dart';

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
