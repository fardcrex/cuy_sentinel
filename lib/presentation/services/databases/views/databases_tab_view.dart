import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/reconnecting_banner.dart';
import '../cubit/databases_cubit.dart';
import '../cubit/databases_state.dart';
import '../database_model.dart';
import '../widgets/phase2_db_card.dart';
import '../widgets/phase_pill.dart';
import '../widgets/schema_card.dart';
import '../widgets/supabase_card.dart';

class DatabasesTabView extends StatelessWidget {
  const DatabasesTabView({super.key, this.physics});

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DatabasesCubit>().state;

    if (state is DatabasesInitial || state is DatabasesLoading) {
      return const Center(child: CircularProgressIndicator());
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
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          physics: physics,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loaded.isReconnecting)
                ReconnectingBanner(secondsLeft: loaded.reconnectingInSeconds),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PhasePill(label: '1 activa', color: AppColors.primary),
                        PhasePill(label: '2 en Fase 2', color: AppColors.textInactive),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: SupabaseCard(model: model)),
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
                            description: 'Instancia auto-hospedada en Ubuntu 24.04. '
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
              ),
            ],
          ),
        );
      },
    );
  }
}
