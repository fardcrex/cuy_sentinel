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
          create: (ctx) =>
              MetricsCubit(getHistory: ctx.read<GetMetricsHistoryUseCase>())
                ..init(),
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

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                child: const ScreenHeader(
                  title: 'Servicios',
                  subtitle:
                      'Servicios monitoreados vía SNMP y almacenamiento de datos',
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabDelegate(
                padding: padding,
                child: ServicesTabSwitcher(
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _tab == 0
                  ? ServicesTabView(
                      physics: const NeverScrollableScrollPhysics(),
                    )
                  : DatabasesTabView(
                      physics: const NeverScrollableScrollPhysics(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabDelegate({required this.padding, required this.child});

  final double padding;
  final Widget child;

  static const double _verticalPadding = 10.0;
  static const double _tabHeight = 42.0;

  @override
  double get minExtent => _tabHeight + _verticalPadding * 2;

  @override
  double get maxExtent => _tabHeight + _verticalPadding * 2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: _verticalPadding,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabDelegate old) =>
      old.padding != padding || old.child != child;
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
    return Center(
      child: Container(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
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
      ),
    );
  }
}
