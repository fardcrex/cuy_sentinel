import 'package:cuy_sentinel/core/env/app_env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/reconnecting_banner.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../cubit/databases_cubit.dart';
import '../cubit/databases_state.dart';
import '../database_model.dart';
import '../widgets/db_nodes_card.dart';
import '../widgets/phase2_db_card.dart';
import '../widgets/phase_pill.dart';
import '../widgets/schema_card.dart';
import '../widgets/supabase_card.dart';

// True when running with --dart-define-from-file=envs/sentinel.phase2.json
const _isPhase2 = AppEnv.apiBaseUrl != '';

class DatabasesTabView extends StatelessWidget {
  const DatabasesTabView({super.key, this.physics});

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DatabasesCubit>().state;

    if (state is DatabasesInitial || state is DatabasesLoading) {
      return DatabasesTabLoadingSkeleton(physics: physics);
    }
    if (state is DatabasesError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: AppColors.danger),
        ),
      );
    }

    final loaded = state as DatabasesLoaded;
    final model = loaded.health.toModel(loaded.tableStats);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          physics: physics,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loaded.isReconnecting)
                ReconnectingBanner(secondsLeft: loaded.reconnectingInSeconds),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  padding,
                  padding,
                  padding + bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_isPhase2) ...[
                          PhasePill(
                            label: '2 activa',
                            color: AppColors.secondary,
                          ),
                          PhasePill(
                            label: '1 · Supabase depreciado',
                            color: AppColors.textInactive,
                          ),
                        ] else ...[
                          PhasePill(
                            label: '1 activa',
                            color: AppColors.primary,
                          ),
                          PhasePill(
                            label: '2 en Fase 2',
                            color: AppColors.textInactive,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isWide)
                      // Phase 2: PostgreSQL cards take the main left column;
                      // Supabase moves to the secondary right column (below schema).
                      // Phase 1: Supabase is the main left card.
                      if (_isPhase2)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Phase2DbCard(
                                    title: 'PostgreSQL Primario',
                                    subtitle: 'Base de datos principal · activo',
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
                                    enabled: true,
                                  ),
                                  SizedBox(height: 20),
                                  Phase2DbCard(
                                    title: 'PostgreSQL Réplica',
                                    subtitle:
                                        'Réplica streaming activa · hot standby',
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
                                    enabled: true,
                                  ),
                                  SizedBox(height: 20),
                                  DbNodesCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  const SchemaCard(),
                                  const SizedBox(height: 20),
                                  SupabaseCard(
                                    model: model,
                                    enabled: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: SupabaseCard(model: model),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  SchemaCard(),
                                  SizedBox(height: 20),
                                  Phase2DbCard(
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
                                  Phase2DbCard(
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
                    else if (_isPhase2)
                      Column(
                        children: [
                          const SchemaCard(),
                          const SizedBox(height: 20),
                          const Phase2DbCard(
                            title: 'PostgreSQL Primario',
                            subtitle: 'Base de datos principal · activo',
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
                            enabled: true,
                          ),
                          const SizedBox(height: 20),
                          const Phase2DbCard(
                            title: 'PostgreSQL Réplica',
                            subtitle: 'Réplica streaming activa · hot standby',
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
                            enabled: true,
                          ),
                          const SizedBox(height: 20),
                          const DbNodesCard(),
                          const SizedBox(height: 20),
                          SupabaseCard(model: model, enabled: false),
                        ],
                      )
                    else
                      Column(
                        children: [
                          SupabaseCard(model: model),
                          const SizedBox(height: 20),
                          const SchemaCard(),
                          const SizedBox(height: 20),
                          const Phase2DbCard(
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
                          const SizedBox(height: 20),
                          const Phase2DbCard(
                            title: 'PostgreSQL Réplica',
                            subtitle: _isPhase2
                                ? 'Réplica streaming activa · hot standby'
                                : 'Alta disponibilidad — streaming WAL',
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
                            enabled: _isPhase2,
                          ),
                        ],
                      ),
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

class DatabasesTabLoadingSkeleton extends StatelessWidget {
  const DatabasesTabLoadingSkeleton({super.key, this.physics});

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = AppBreakpoints.isDesktop(width);

        return LoadingSkeletonPulse(
          child: SingleChildScrollView(
            physics: physics,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                padding,
                padding,
                padding,
                padding + bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SkeletonBlock(width: 82, height: 30, radius: 999),
                      SkeletonBlock(width: 104, height: 30, radius: 999),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _SupabaseSkeleton()),
                        SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _SchemaSkeleton(),
                              SizedBox(height: 20),
                              _PhaseDbSkeleton(),
                              SizedBox(height: 20),
                              _PhaseDbSkeleton(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        _SupabaseSkeleton(),
                        SizedBox(height: 20),
                        _SchemaSkeleton(),
                        SizedBox(height: 20),
                        _PhaseDbSkeleton(),
                        SizedBox(height: 20),
                        _PhaseDbSkeleton(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SupabaseSkeleton extends StatelessWidget {
  const _SupabaseSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBlock(width: 48, height: 48, radius: 16),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(width: 190, height: 22),
                    SizedBox(height: 8),
                    SkeletonBlock(width: 150, height: 13),
                  ],
                ),
              ),
              SizedBox(width: 14),
              SkeletonBlock(width: 82, height: 28, radius: 999),
            ],
          ),
          SizedBox(height: 24),
          SkeletonBlock(width: double.infinity, height: 150, radius: 18),
          SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SkeletonBlock(width: 130, height: 54, radius: 14),
              SkeletonBlock(width: 130, height: 54, radius: 14),
              SkeletonBlock(width: 130, height: 54, radius: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchemaSkeleton extends StatelessWidget {
  const _SchemaSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 170, height: 22),
          SizedBox(height: 16),
          SkeletonBlock(width: double.infinity, height: 12),
          SizedBox(height: 10),
          SkeletonBlock(width: 220, height: 12),
          SizedBox(height: 18),
          _SchemaRowSkeleton(width: 90),
          SizedBox(height: 10),
          _SchemaRowSkeleton(width: 130),
          SizedBox(height: 10),
          _SchemaRowSkeleton(width: 110),
          SizedBox(height: 10),
          _SchemaRowSkeleton(width: 150),
        ],
      ),
    );
  }
}

class _PhaseDbSkeleton extends StatelessWidget {
  const _PhaseDbSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 190, height: 22),
          SizedBox(height: 8),
          SkeletonBlock(width: 230, height: 13),
          SizedBox(height: 16),
          SkeletonBlock(width: double.infinity, height: 12),
          SizedBox(height: 8),
          SkeletonBlock(width: 260, height: 12),
          SizedBox(height: 18),
          _SchemaRowSkeleton(width: 180),
          SizedBox(height: 10),
          _SchemaRowSkeleton(width: 220),
          SizedBox(height: 10),
          _SchemaRowSkeleton(width: 160),
        ],
      ),
    );
  }
}

class _SchemaRowSkeleton extends StatelessWidget {
  const _SchemaRowSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBlock(width: 8, height: 8, radius: 999),
        const SizedBox(width: 10),
        SkeletonBlock(width: width, height: 13),
      ],
    );
  }
}
