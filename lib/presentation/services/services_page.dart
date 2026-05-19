import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../feature/databases/application/get_database_health_use_case.dart';
import '../../feature/metrics/application/get_metrics_history_use_case.dart';
import '../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../feature/monitoring/application/get_services_use_case.dart';
import '../metrics/cubit/metrics_cubit.dart';
import '../widgets/screen_header.dart';
import 'databases/cubit/databases_cubit.dart';
import 'databases/views/databases_tab_view.dart';
import 'monitored_services/cubit/services_cubit.dart';
import 'monitored_services/views/services_tab_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class ServicesProviderPage extends StatelessWidget {
  const ServicesProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ServicesCubit>(
          create: (ctx) => ServicesCubit(
            getServices: ctx.read<GetServicesUseCase>(),
            watchEvents: ctx.read<WatchActiveEventsUseCase>(),
            watchRun: ctx.read<WatchLastCollectorRunUseCase>(),
          )..load(),
        ),
        BlocProvider<MetricsCubit>(
          create: (ctx) => MetricsCubit(
            getHistory: ctx.read<GetMetricsHistoryUseCase>(),
          )..init(),
        ),
        BlocProvider<DatabasesCubit>(
          create: (ctx) => DatabasesCubit(
            watchHealth: ctx.read<WatchDatabaseHealthUseCase>(),
            getTableStats: ctx.read<GetTableStatsUseCase>(),
          )..load(),
        ),
      ],
      child: const ServicesPage(),
    );
  }
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
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
                trailing: ServicesTabSwitcher(
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            Expanded(
              child: _tab == 0
                  ? const ServicesTabView()
                  : const DatabasesTabView(),
            ),
          ],
        );
      },
    );
  }
}

// ── tab switcher ──────────────────────────────────────────────────────────────

class ServicesTabSwitcher extends StatelessWidget {
  const ServicesTabSwitcher({
    super.key,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                  color:
                      selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
