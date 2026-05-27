import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../feature/monitoring/domain/entities/db_node.dart';
import '../../../widgets/app_card.dart';
import '../cubit/db_nodes_cubit.dart';
import '../cubit/db_nodes_state.dart';

class DbNodesCard extends StatelessWidget {
  const DbNodesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DbNodesCubit, DbNodesState>(
      builder: (context, state) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onRefresh: context.read<DbNodesCubit>().refresh),
              const SizedBox(height: 16),
              switch (state) {
                DbNodesLoading() || DbNodesInitial() => const _LoadingView(),
                DbNodesError(:final message) => _ErrorView(
                    message,
                    onRetry: context.read<DbNodesCubit>().refresh,
                  ),
                DbNodesLoaded(:final nodes) => nodes.isEmpty
                    ? const _EmptyView()
                    : _NodesList(nodes),
              },
            ],
          ),
        );
      },
    );
  }
}

// ── header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nodos Patroni',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Estado en tiempo real del clúster PostgreSQL',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          color: AppColors.textSecondary,
          tooltip: 'Actualizar',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.stroke),
            ),
          ),
        ),
      ],
    );
  }
}

// ── states ────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message, {required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.danger,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.danger, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Reintentar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

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

// ── nodes list ────────────────────────────────────────────────────────────────

class _NodesList extends StatelessWidget {
  const _NodesList(this.nodes);

  final List<DbNode> nodes;

  @override
  Widget build(BuildContext context) {
    final healthy = nodes.where((n) => n.isHealthy).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < nodes.length; i++) ...[
          _NodeRow(node: nodes[i]),
          if (i < nodes.length - 1)
            const Divider(color: AppColors.stroke, height: 1, thickness: 1),
        ],
        const SizedBox(height: 14),
        _SummaryBar(healthy: healthy, total: nodes.length),
      ],
    );
  }
}

class _NodeRow extends StatelessWidget {
  const _NodeRow({required this.node});

  final DbNode node;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: node.statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: node.statusColor.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Name
          Expanded(
            flex: 3,
            child: Text(
              node.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Role chip
          _RoleChip(node: node),
          const SizedBox(width: 8),
          // State
          Expanded(
            flex: 2,
            child: Text(
              node.state ?? '—',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Lag
          SizedBox(
            width: 56,
            child: Text(
              _lagLabel(node.lag),
              style: TextStyle(
                fontSize: 12,
                color: node.lag != null && node.lag! > 0
                    ? AppColors.warning
                    : AppColors.textInactive,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 12),
          // PG version
          Text(
            node.pgVersion,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textInactive,
            ),
          ),
        ],
      ),
    );
  }

  String _lagLabel(int? lag) {
    if (lag == null) return '—';
    if (lag == 0) return '0 B';
    if (lag < 1024) return '$lag B';
    if (lag < 1048576) return '${(lag / 1024).toStringAsFixed(1)} KB';
    return '${(lag / 1048576).toStringAsFixed(1)} MB';
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.node});

  final DbNode node;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: node.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: node.statusColor.withValues(alpha: 0.30)),
      ),
      child: Text(
        node.roleLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: node.statusColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.healthy, required this.total});

  final int healthy;
  final int total;

  @override
  Widget build(BuildContext context) {
    final allOk = healthy == total;
    return Row(
      children: [
        Icon(
          allOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
          size: 14,
          color: allOk ? AppColors.primary : AppColors.warning,
        ),
        const SizedBox(width: 6),
        Text(
          allOk
              ? '$total/$total nodos activos'
              : '$healthy/$total nodos activos',
          style: TextStyle(
            fontSize: 12,
            color: allOk ? AppColors.primary : AppColors.warning,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
