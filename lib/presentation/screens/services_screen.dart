import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Servicios',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vista simple de servicios monitoreados y su estado actual.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: AppBreakpoints.isDesktop(width)
                    ? Row(
                        children: [
                          Expanded(child: _ServiceList(width: width * 0.5)),
                          SizedBox(width: 20),
                          Expanded(child: _ServicesIllustration()),
                        ],
                      )
                    : Column(
                        children: [
                          _ServiceList(width: width),
                          SizedBox(height: 20),
                          _ServicesIllustration(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(width);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 1 : 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: isMobile ? 2.35 : 0.95,
      children: const [
        _ServiceTile(
          name: 'Passbolt',
          description: 'Uptime 99.9% y respuesta saludable.',
          tag: 'Online',
          color: AppColors.primary,
          imagePath: AppAssets.badgePassboltSuccess,
        ),
        _ServiceTile(
          name: 'ChkMonitor',
          description: 'Monitoreo activo y tráfico estable.',
          tag: 'Online',
          color: AppColors.secondary,
          imagePath: AppAssets.badgeServerSuccess,
        ),
        _ServiceTile(
          name: 'SNMP Core',
          description: 'Colector principal listo para crecer con más nodos.',
          tag: 'Listo',
          color: AppColors.primaryBright,
          imagePath: AppAssets.badgeSnmpSuccess,
        ),
        _ServiceTile(
          name: 'Base de datos',
          description:
              'Base de datos principal lista para crecer con más nodos.',
          tag: 'Listo',
          color: AppColors.primaryBright,
          imagePath: AppAssets.badgeBdSuccess,
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.name,
    required this.description,
    required this.tag,
    required this.color,
    required this.imagePath,
  });

  final String name;
  final String description;
  final String tag;
  final Color color;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.stroke),
      ),
      child: isMobile
          ? Row(
              children: [
                Image.asset(imagePath, width: 160, height: 160),
                const SizedBox(width: 14),
                Expanded(
                  child: _ServiceTileBody(name: name, description: description),
                ),
                const SizedBox(width: 12),
                _ServiceTag(tag: tag, color: color),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    _ServiceTag(tag: tag, color: color),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Image.asset(imagePath, width: 160, height: 160),
                  ),
                ),
                const SizedBox(height: 14),
                _ServiceTileBody(name: null, description: description),
              ],
            ),
    );
  }
}

class _ServiceTileBody extends StatelessWidget {
  const _ServiceTileBody({required this.name, required this.description});

  final String? name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (name != null) ...[
          Text(name!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
        ],
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ServiceTag extends StatelessWidget {
  const _ServiceTag({required this.tag, required this.color});

  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(tag, style: TextStyle(color: color)),
    );
  }
}

class _ServicesIllustration extends StatelessWidget {
  const _ServicesIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          AppAssets.illustrationMonitoringGuard,
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          'La base de servicios queda preparada para crecer sin decidir todavía la estructura final por features.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
