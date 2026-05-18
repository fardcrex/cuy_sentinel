import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import 'widgets/screen_header.dart';
import 'widgets/service_detail_card.dart';
import 'widgets/status_badge.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);

        return Column(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
              child: ScreenHeader(
                title: 'Servicios',
                subtitle:
                    'Servicios monitoreados vía SNMP y almacenamiento de datos',
                trailing: _TabSwitcher(
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            Expanded(
              child: _tab == 0
                  ? _ServicesTab(width: width, padding: padding)
                  : _DatabasesTab(width: width, padding: padding),
            ),
          ],
        );
      },
    );
  }
}

// ─── Tab switcher ──────────────────────────────────────────────────────────────

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _labels = ['Servicios', 'Bases de datos'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_labels.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: selected
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      )
                    : null,
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Servicios tab ─────────────────────────────────────────────────────────────

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.width, required this.padding});

  final double width;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final isWide = width >= 900;
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.30),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors_rounded,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      '2 en línea',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isWide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ServiceDetailCard(
                    name: 'Passbolt',
                    containerName: 'passbolt_app',
                    host: '192.168.1.10',
                    snmpPort: 1161,
                    status: ServiceStatus.online,
                    cpuPercent: 45,
                    ramUsedMb: 612,
                    ramTotalMb: 2048,
                    diskPercent: 58,
                    bwInMbps: 2.3,
                    bwOutMbps: 1.1,
                    uptimeLabel: '3d 14h 23m',
                    imagePath: AppAssets.badgePassboltSuccess,
                    accentColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ServiceDetailCard(
                    name: 'ChkMonitor',
                    containerName: 'chkmonitor_app',
                    host: '192.168.1.10',
                    snmpPort: 2161,
                    status: ServiceStatus.online,
                    cpuPercent: 12,
                    ramUsedMb: 256,
                    ramTotalMb: 1024,
                    diskPercent: 44,
                    bwInMbps: 0.8,
                    bwOutMbps: 0.4,
                    uptimeLabel: '3d 14h 23m',
                    imagePath: AppAssets.badgeServerSuccess,
                    accentColor: AppColors.secondary,
                  ),
                ),
              ],
            )
          else
            const Column(
              children: [
                ServiceDetailCard(
                  name: 'Passbolt',
                  containerName: 'passbolt_app',
                  host: '192.168.1.10',
                  snmpPort: 1161,
                  status: ServiceStatus.online,
                  cpuPercent: 45,
                  ramUsedMb: 612,
                  ramTotalMb: 2048,
                  diskPercent: 58,
                  bwInMbps: 2.3,
                  bwOutMbps: 1.1,
                  uptimeLabel: '3d 14h 23m',
                  imagePath: AppAssets.badgePassboltSuccess,
                  accentColor: AppColors.primary,
                ),
                SizedBox(height: 20),
                ServiceDetailCard(
                  name: 'ChkMonitor',
                  containerName: 'chkmonitor_app',
                  host: '192.168.1.10',
                  snmpPort: 2161,
                  status: ServiceStatus.online,
                  cpuPercent: 12,
                  ramUsedMb: 256,
                  ramTotalMb: 1024,
                  diskPercent: 44,
                  bwInMbps: 0.8,
                  bwOutMbps: 0.4,
                  uptimeLabel: '3d 14h 23m',
                  imagePath: AppAssets.badgeServerSuccess,
                  accentColor: AppColors.secondary,
                ),
              ],
            ),
          const SizedBox(height: 24),
          const _InfrastructureCard(),
        ],
      ),
    );
  }
}

// ─── Bases de datos tab ────────────────────────────────────────────────────────

class _DatabasesTab extends StatelessWidget {
  const _DatabasesTab({required this.width, required this.padding});

  final double width;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final isWide = AppBreakpoints.isDesktop(width);
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PhasePill(label: '1 activa', color: AppColors.primary),
              _PhasePill(label: '2 en Fase 2', color: AppColors.textInactive),
            ],
          ),
          const SizedBox(height: 20),
          if (isWide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _SupabaseCard()),
                SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _SchemaCard(),
                      SizedBox(height: 20),
                      _Phase2DbCard(
                        title: 'PostgreSQL Primario',
                        subtitle: 'Reemplazará a Supabase en Fase 2',
                        description:
                            'Instancia auto-hospedada en Ubuntu 24.04. '
                            'Control total sobre configuración, índices y vacuuming. '
                            'Actúa como nodo primario para la réplica streaming.',
                        features: [
                          'Acceso local en red privada',
                          'Configuración avanzada (pg_hba, postgresql.conf)',
                          'WAL archiving habilitado',
                          'Monitoreo con pg_stat_activity',
                        ],
                      ),
                      SizedBox(height: 20),
                      _Phase2DbCard(
                        title: 'PostgreSQL Réplica',
                        subtitle: 'Alta disponibilidad — streaming WAL',
                        description:
                            'Réplica asíncrona de streaming desde el nodo primario. '
                            'Reduce latencia de lecturas y permite failover automático '
                            'ante caída del primario.',
                        features: [
                          'Réplica streaming asíncrona',
                          'Solo lectura (hot standby)',
                          'Failover manual/automático',
                          'Desfase de replicación visible',
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const Column(
              children: [
                _SupabaseCard(),
                SizedBox(height: 20),
                _SchemaCard(),
                SizedBox(height: 20),
                _Phase2DbCard(
                  title: 'PostgreSQL Primario',
                  subtitle: 'Reemplazará a Supabase en Fase 2',
                  description:
                      'Instancia auto-hospedada en Ubuntu 24.04. '
                      'Control total sobre configuración, índices y vacuuming. '
                      'Actúa como nodo primario para la réplica streaming.',
                  features: [
                    'Acceso local en red privada',
                    'Configuración avanzada (pg_hba, postgresql.conf)',
                    'WAL archiving habilitado',
                    'Monitoreo con pg_stat_activity',
                  ],
                ),
                SizedBox(height: 20),
                _Phase2DbCard(
                  title: 'PostgreSQL Réplica',
                  subtitle: 'Alta disponibilidad — streaming WAL',
                  description:
                      'Réplica asíncrona de streaming desde el nodo primario. '
                      'Reduce latencia de lecturas y permite failover automático '
                      'ante caída del primario.',
                  features: [
                    'Réplica streaming asíncrona',
                    'Solo lectura (hot standby)',
                    'Failover manual/automático',
                    'Desfase de replicación visible',
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Infraestructura SNMP card ─────────────────────────────────────────────────

class _InfrastructureCard extends StatelessWidget {
  const _InfrastructureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: AppColors.primaryBright,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Infraestructura SNMP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _InfraChip(
                icon: Icons.dns_rounded,
                label: 'Ubuntu 24.04 LTS',
                color: AppColors.secondary,
              ),
              _InfraChip(
                icon: Icons.precision_manufacturing_rounded,
                label: 'Docker Compose',
                color: AppColors.primaryBright,
              ),
              _InfraChip(
                icon: Icons.wifi_tethering_rounded,
                label: 'SNMP v2c',
                color: AppColors.primary,
              ),
              _InfraChip(
                icon: Icons.storage_rounded,
                label: 'Supabase (Fase 1)',
                color: AppColors.warning,
              ),
              _InfraChip(
                icon: Icons.code_rounded,
                label: 'Go Collector',
                color: AppColors.chartCpu,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfraChip extends StatelessWidget {
  const _InfraChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supabase active card ──────────────────────────────────────────────────────

class _SupabaseCard extends StatelessWidget {
  const _SupabaseCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              height: 188,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  Image.asset(
                    AppAssets.badgeBdSuccess,
                    width: 156,
                    height: 156,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supabase',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PostgreSQL 15 · Cloud',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'us-east-1 · cuy-sentinel-db',
                        style: TextStyle(
                          color: AppColors.textInactive,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const StatusBadge(status: ServiceStatus.online),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Fase 1',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _DbChip(
                  icon: Icons.speed_rounded,
                  label: 'Latencia',
                  value: '28 ms',
                  color: AppColors.primary,
                ),
                _DbChip(
                  icon: Icons.storage_rounded,
                  label: 'Almacenamiento',
                  value: '124 MB',
                  color: AppColors.chartRam,
                ),
                _DbChip(
                  icon: Icons.cached_rounded,
                  label: 'Cache hit',
                  value: '99.2%',
                  color: AppColors.secondary,
                ),
                _DbChip(
                  icon: Icons.link_rounded,
                  label: 'Conexiones',
                  value: '3 activas',
                  color: AppColors.chartNetwork,
                ),
                _DbChip(
                  icon: Icons.table_chart_outlined,
                  label: 'Tablas',
                  value: '5',
                  color: AppColors.chartDisk,
                ),
                _DbChip(
                  icon: Icons.numbers_rounded,
                  label: 'Filas totales',
                  value: '12,698',
                  color: AppColors.primaryBright,
                ),
                _DbChip(
                  icon: Icons.access_time_rounded,
                  label: 'Última escritura',
                  value: 'Hace 3 min',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Conteo de filas por tabla',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                _TableRow(
                  name: 'metrics',
                  rows: '12,540',
                  description: 'Lecturas SNMP cada 5 min',
                  color: AppColors.chartCpu,
                ),
                SizedBox(height: 8),
                _TableRow(
                  name: 'collector_runs',
                  rows: '150',
                  description: 'Ejecuciones del agente Go',
                  color: AppColors.secondary,
                ),
                SizedBox(height: 8),
                _TableRow(
                  name: 'service_events',
                  rows: '3',
                  description: 'Incidentes registrados',
                  color: AppColors.warning,
                ),
                SizedBox(height: 8),
                _TableRow(
                  name: 'monitored_services',
                  rows: '2',
                  description: 'Passbolt · ChkMonitor',
                  color: AppColors.primary,
                ),
                SizedBox(height: 8),
                _TableRow(
                  name: 'users',
                  rows: '3',
                  description: 'Admin + 2 visualizadores',
                  color: AppColors.primaryBright,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Schema / architecture card ────────────────────────────────────────────────

class _SchemaCard extends StatelessWidget {
  const _SchemaCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.iconDatabaseSync,
              width: 140,
              height: 140,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Arquitectura de datos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Patrón de interfaces IMonitoringRepository '
            'permite migrar de Supabase a PostgreSQL propio '
            'sin alterar la lógica del panel.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const _ArchRow(
            icon: Icons.cloud_outlined,
            label: 'Supabase REST + Realtime',
            phase: 'Fase 1',
            active: true,
          ),
          const SizedBox(height: 10),
          const _ArchRow(
            icon: Icons.dns_rounded,
            label: 'PostgreSQL + Node.js API',
            phase: 'Fase 2',
            active: false,
          ),
          const SizedBox(height: 10),
          const _ArchRow(
            icon: Icons.copy_all_rounded,
            label: 'Réplica streaming WAL',
            phase: 'Fase 2',
            active: false,
          ),
        ],
      ),
    );
  }
}

class _ArchRow extends StatelessWidget {
  const _ArchRow({
    required this.icon,
    required this.label,
    required this.phase,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String phase;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textInactive;
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: active ? AppColors.textPrimary : AppColors.textInactive,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            phase,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Phase 2 locked card ───────────────────────────────────────────────────────

class _Phase2DbCard extends StatelessWidget {
  const _Phase2DbCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
  });

  final String title;
  final String subtitle;
  final String description;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.45,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textInactive.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.storage_rounded,
                        color: AppColors.textInactive,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textInactive),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                for (final f in features) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: AppColors.textInactive,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textInactive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.panel.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.stroke.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textInactive,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Text(
                      'Se habilitará en Fase 2',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PostgreSQL auto-hospedado · Ubuntu 24.04',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textInactive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared small widgets ──────────────────────────────────────────────────────

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DbChip extends StatelessWidget {
  const _DbChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.name,
    required this.rows,
    required this.description,
    required this.color,
  });

  final String name;
  final String rows;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            rows,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            ' filas',
            style: TextStyle(color: AppColors.textInactive, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
