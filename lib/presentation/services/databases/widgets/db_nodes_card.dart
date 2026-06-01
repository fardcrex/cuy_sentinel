import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../feature/monitoring/domain/entities/db_node.dart';
import '../../../widgets/loading_skeleton.dart';
import '../cubit/db_nodes_cubit.dart';
import '../cubit/db_nodes_state.dart';

class DbNodesCard extends StatelessWidget {
  const DbNodesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DbNodesCubit, DbNodesState>(
      builder: (context, state) => switch (state) {
        DbNodesInitial() || DbNodesLoading() => const _Skeleton(),
        DbNodesError(:final message) => _ErrorCard(
            message: message,
            onRetry: context.read<DbNodesCubit>().refresh,
          ),
        DbNodesLoaded(:final nodes) => _ClusterCard(
            nodes: nodes,
            onRefresh: context.read<DbNodesCubit>().refresh,
          ),
      },
    );
  }
}

// ── Cluster card ──────────────────────────────────────────────────────────────

class _ClusterCard extends StatelessWidget {
  const _ClusterCard({required this.nodes, required this.onRefresh});

  final List<DbNode> nodes;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final healthy = nodes.where((n) => n.isHealthy).length;
    final allOk = healthy == nodes.length && nodes.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: allOk
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.danger.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: (allOk ? AppColors.primary : AppColors.danger)
                .withValues(alpha: 0.07),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            nodeCount: nodes.length,
            allOk: allOk,
            onRefresh: onRefresh,
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.stroke),
          Padding(
            padding: const EdgeInsets.all(20),
            child: nodes.isEmpty
                ? const _EmptyNodes()
                : _NodesLayout(nodes: nodes),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.stroke),
          _ClusterFooter(healthy: healthy, total: nodes.length, allOk: allOk),
        ],
      ),
    );
  }
}

// ── Card header ───────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.nodeCount,
    required this.allOk,
    required this.onRefresh,
  });

  final int nodeCount;
  final bool allOk;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: AppColors.background,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clúster Patroni',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PostgreSQL · $nodeCount nodos · replicación streaming WAL',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _LiveBadge(allOk: allOk),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            color: AppColors.textSecondary,
            tooltip: 'Actualizar',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.stroke),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live badge ────────────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.allOk});
  final bool allOk;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.allOk ? AppColors.primary : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.65),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nodes layout ──────────────────────────────────────────────────────────────

class _NodesLayout extends StatelessWidget {
  const _NodesLayout({required this.nodes});

  final List<DbNode> nodes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final primary =
            nodes.where((n) => n.role == DbNodeRole.primary).toList();
        final replicas =
            nodes.where((n) => n.role != DbNodeRole.primary).toList();
        final isWide = constraints.maxWidth >= 460;

        if (isWide && nodes.length >= 2) {
          return _WideLayout(primary: primary, replicas: replicas);
        }
        return _NarrowLayout(primary: primary, replicas: replicas);
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.primary, required this.replicas});

  final List<DbNode> primary;
  final List<DbNode> replicas;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                for (final n in primary) Expanded(child: _NodeTile(node: n)),
              ],
            ),
          ),
          if (replicas.isNotEmpty) ...[
            const _HorizontalReplicationConnector(),
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < replicas.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    Expanded(child: _NodeTile(node: replicas[i])),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.primary, required this.replicas});

  final List<DbNode> primary;
  final List<DbNode> replicas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final n in primary) _NodeTile(node: n),
        if (replicas.isNotEmpty) ...[
          const _VerticalReplicationConnector(),
          for (int i = 0; i < replicas.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _NodeTile(node: replicas[i]),
          ],
        ],
      ],
    );
  }
}

// ── Node tile ─────────────────────────────────────────────────────────────────

class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node});

  final DbNode node;

  @override
  Widget build(BuildContext context) {
    final color = node.statusColor;
    final isPrimary = node.role == DbNodeRole.primary;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPrimary ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isPrimary ? 0.28 : 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isPrimary ? 0.13 : 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Icon(
                  isPrimary
                      ? Icons.star_rounded
                      : Icons.content_copy_rounded,
                  color: color,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Text(
                  node.roleLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                _StatusPill(node: node),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${node.host}:${node.port}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textInactive,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (node.state != null)
                      _InfoChip(label: node.state!),
                    if (node.timeline != null)
                      _InfoChip(label: 'TL ${node.timeline}'),
                    if (node.lag != null &&
                        node.role != DbNodeRole.primary)
                      _InfoChip(
                        label: 'Lag ${_lagLabel(node.lag!)}',
                        warn: node.lag! > 0,
                      ),
                    _InfoChip(label: node.pgVersion),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _lagLabel(int lag) {
    if (lag == 0) return '0 B';
    if (lag < 1024) return '$lag B';
    if (lag < 1048576) return '${(lag / 1024).toStringAsFixed(1)} KB';
    return '${(lag / 1048576).toStringAsFixed(1)} MB';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.node});
  final DbNode node;

  @override
  Widget build(BuildContext context) {
    final color = node.statusColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          node.isHealthy ? 'activo' : 'caído',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.warn = false});
  final String label;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final color = warn ? AppColors.warning : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: warn
            ? AppColors.warning.withValues(alpha: 0.10)
            : AppColors.panel.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: warn
              ? AppColors.warning.withValues(alpha: 0.30)
              : AppColors.stroke,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Replication connectors ────────────────────────────────────────────────────

class _HorizontalReplicationConnector extends StatelessWidget {
  const _HorizontalReplicationConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withValues(alpha: 0),
                  AppColors.secondary.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.secondary,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            'WAL',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary.withValues(alpha: 0.7),
              letterSpacing: 0.8,
            ),
          ),
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.5),
                  AppColors.secondary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalReplicationConnector extends StatelessWidget {
  const _VerticalReplicationConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 14,
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
              const Icon(
                Icons.arrow_downward_rounded,
                color: AppColors.secondary,
                size: 16,
              ),
              Container(
                width: 2,
                height: 14,
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            'streaming WAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _ClusterFooter extends StatelessWidget {
  const _ClusterFooter({
    required this.healthy,
    required this.total,
    required this.allOk,
  });

  final int healthy;
  final int total;
  final bool allOk;

  @override
  Widget build(BuildContext context) {
    final color = allOk ? AppColors.primary : AppColors.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(
            allOk
                ? Icons.verified_rounded
                : Icons.warning_amber_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            allOk
                ? '$healthy/$total nodos activos · Clúster saludable'
                : '$healthy/$total nodos activos · Verificar clúster',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Patroni · HA PostgreSQL',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textInactive,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Error ─────────────────────────────────────────────────────────────

class _EmptyNodes extends StatelessWidget {
  const _EmptyNodes();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Sin nodos disponibles',
          style: TextStyle(color: AppColors.textInactive, fontSize: 13),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.danger,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Clúster Patroni no disponible',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: AppColors.danger, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.40)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return LoadingSkeletonPulse(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              child: Row(
                children: [
                  const SkeletonBlock(width: 46, height: 46, radius: 14),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(width: 160, height: 18),
                        SizedBox(height: 6),
                        SkeletonBlock(width: 240, height: 13),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SkeletonBlock(width: 62, height: 30, radius: 20),
                  const SizedBox(width: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.stroke.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.stroke),
            Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 460;
                  if (isWide) {
                    return const Row(
                      children: [
                        Expanded(child: _NodeSkeleton()),
                        SizedBox(width: 48),
                        Expanded(child: _NodeSkeleton()),
                      ],
                    );
                  }
                  return const Column(
                    children: [
                      _NodeSkeleton(),
                      SizedBox(height: 12),
                      _NodeSkeleton(),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.stroke),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SkeletonBlock(width: 260, height: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeSkeleton extends StatelessWidget {
  const _NodeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.stroke.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.stroke.withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 140, height: 18),
                SizedBox(height: 6),
                SkeletonBlock(width: 110, height: 12),
                SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SkeletonBlock(width: 72, height: 26, radius: 8),
                    SkeletonBlock(width: 52, height: 26, radius: 8),
                    SkeletonBlock(width: 62, height: 26, radius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
