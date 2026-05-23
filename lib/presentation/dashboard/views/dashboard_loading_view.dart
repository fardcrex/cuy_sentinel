import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_skeleton.dart';

class DashboardLoadingView extends StatelessWidget {
  const DashboardLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = width >= 1100;

        return LoadingSkeletonPulse(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DashboardHeaderSkeleton(),
                const SizedBox(height: 24),
                const _DashboardStatsSkeleton(),
                const SizedBox(height: 24),
                if (isWide)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _ChartCardSkeleton(titleWidth: 160),
                            SizedBox(height: 20),
                            _BandwidthCardSkeleton(),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _SideCardSkeleton(titleWidth: 170, rows: 2),
                            SizedBox(height: 20),
                            _SideCardSkeleton(titleWidth: 150, rows: 3),
                            SizedBox(height: 20),
                            _SideCardSkeleton(titleWidth: 160, rows: 4),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const Column(
                    children: [
                      _SideCardSkeleton(titleWidth: 170, rows: 2),
                      SizedBox(height: 20),
                      _ChartCardSkeleton(titleWidth: 160),
                      SizedBox(height: 20),
                      _BandwidthCardSkeleton(),
                      SizedBox(height: 20),
                      _SideCardSkeleton(titleWidth: 150, rows: 3),
                      SizedBox(height: 20),
                      _SideCardSkeleton(titleWidth: 160, rows: 4),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeaderSkeleton extends StatelessWidget {
  const _DashboardHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 16,
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 190, height: 32),
            SizedBox(height: 10),
            SkeletonBlock(width: 260, height: 16),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonBlock(width: 42, height: 42, radius: 14),
            SizedBox(width: 10),
            SkeletonBlock(width: 42, height: 42, radius: 14),
          ],
        ),
      ],
    );
  }
}

class _DashboardStatsSkeleton extends StatelessWidget {
  const _DashboardStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final columns = width >= 1100 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: width >= 900
              ? 1.6
              : isMobile
              ? 0.95
              : 1.35,
          children: const [
            _StatCardSkeleton(),
            _StatCardSkeleton(),
            _StatCardSkeleton(),
            _StatCardSkeleton(),
          ],
        );
      },
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBlock(width: 36, height: 36, radius: 10),
              Spacer(),
              SkeletonBlock(width: 52, height: 24),
            ],
          ),
          Spacer(),
          SkeletonBlock(width: 78, height: 30),
          SizedBox(height: 8),
          SkeletonBlock(width: 118, height: 14),
          SizedBox(height: 6),
          SkeletonBlock(width: 92, height: 12),
        ],
      ),
    );
  }
}

class _ChartCardSkeleton extends StatelessWidget {
  const _ChartCardSkeleton({required this.titleWidth});

  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: titleWidth, height: 24),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SkeletonBlock(width: 82, height: 32, radius: 12),
              SkeletonBlock(width: 104, height: 32, radius: 12),
              SkeletonBlock(width: 56, height: 32, radius: 12),
              SkeletonBlock(width: 56, height: 32, radius: 12),
              SkeletonBlock(width: 70, height: 32, radius: 12),
            ],
          ),
          const SizedBox(height: 18),
          const SkeletonBlock(width: double.infinity, height: 180, radius: 18),
          const SizedBox(height: 16),
          const _StatsRowSkeleton(),
        ],
      ),
    );
  }
}

class _BandwidthCardSkeleton extends StatelessWidget {
  const _BandwidthCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 170, height: 24),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              SkeletonBlock(width: 66, height: 32, radius: 12),
              SkeletonBlock(width: 82, height: 32, radius: 12),
              SkeletonBlock(width: 104, height: 32, radius: 12),
            ],
          ),
          SizedBox(height: 10),
          SkeletonBlock(width: 180, height: 13),
          SizedBox(height: 18),
          _SeriesSkeleton(),
          SizedBox(height: 20),
          _SeriesSkeleton(),
        ],
      ),
    );
  }
}

class _SeriesSkeleton extends StatelessWidget {
  const _SeriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 86, height: 13),
        SizedBox(height: 8),
        SkeletonBlock(width: double.infinity, height: 100, radius: 18),
        SizedBox(height: 12),
        _StatsRowSkeleton(),
      ],
    );
  }
}

class _SideCardSkeleton extends StatelessWidget {
  const _SideCardSkeleton({required this.titleWidth, required this.rows});

  final double titleWidth;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: titleWidth, height: 24),
          const SizedBox(height: 16),
          ...List.generate(
            rows,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < rows - 1 ? 12 : 0),
              child: const _SideRowSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideRowSkeleton extends StatelessWidget {
  const _SideRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBlock(width: 34, height: 34, radius: 12),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(width: 140, height: 14),
              SizedBox(height: 7),
              SkeletonBlock(width: 96, height: 12),
            ],
          ),
        ),
        SizedBox(width: 12),
        SkeletonBlock(width: 64, height: 24, radius: 999),
      ],
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonBlock(width: double.infinity, height: 42)),
        SizedBox(width: 10),
        Expanded(child: SkeletonBlock(width: double.infinity, height: 42)),
        SizedBox(width: 10),
        Expanded(child: SkeletonBlock(width: double.infinity, height: 42)),
      ],
    );
  }
}
