import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_skeleton.dart';

class MetricsLoadingView extends StatelessWidget {
  const MetricsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = AppBreakpoints.isDesktop(width);

        if (isWide) {
          return LoadingSkeletonPulse(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                padding,
                padding,
                padding,
                padding + bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _MetricsHeaderSkeleton(showFilter: true),
                  SizedBox(height: 26),
                  _MetricsSummarySkeleton(),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _ResourceChartSkeleton(),
                            SizedBox(height: 20),
                            _BandwidthChartSkeleton(),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _UptimeSkeleton(),
                            SizedBox(height: 20),
                            _SnmpHealthSkeleton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return LoadingSkeletonPulse(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                  child: const _MetricsHeaderSkeleton(showFilter: false),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SkeletonFilterDelegate(padding: padding),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    24,
                    padding,
                    padding + bottomPadding,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetricsSummarySkeleton(),
                      SizedBox(height: 24),
                      _ResourceChartSkeleton(),
                      SizedBox(height: 20),
                      _BandwidthChartSkeleton(),
                      SizedBox(height: 20),
                      _UptimeSkeleton(),
                      SizedBox(height: 20),
                      _SnmpHealthSkeleton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricsHeaderSkeleton extends StatelessWidget {
  const _MetricsHeaderSkeleton({required this.showFilter});

  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 16,
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 160, height: 32),
            SizedBox(height: 10),
            SkeletonBlock(width: 260, height: 16),
          ],
        ),
        if (showFilter) const _FilterSkeleton(),
      ],
    );
  }
}

class _FilterSkeleton extends StatelessWidget {
  const _FilterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBlock(width: 74, height: 42, radius: 14),
        SizedBox(width: 8),
        SkeletonBlock(width: 74, height: 42, radius: 14),
        SizedBox(width: 8),
        SkeletonBlock(width: 74, height: 42, radius: 14),
      ],
    );
  }
}

class _MetricsSummarySkeleton extends StatelessWidget {
  const _MetricsSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final columns = width >= 1100
            ? 4
            : isMobile || width >= 600
            ? 2
            : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: width >= 900
              ? 1.5
              : isMobile
              ? 0.9
              : 1.3,
          children: const [
            _MetricSummaryCardSkeleton(),
            _MetricSummaryCardSkeleton(),
            _MetricSummaryCardSkeleton(),
            _MetricSummaryCardSkeleton(),
          ],
        );
      },
    );
  }
}

class _MetricSummaryCardSkeleton extends StatelessWidget {
  const _MetricSummaryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBlock(width: 32, height: 32, radius: 9),
              Spacer(),
              SkeletonBlock(width: 72, height: 24, radius: 999),
            ],
          ),
          Spacer(),
          SkeletonBlock(width: 112, height: 14),
          SizedBox(height: 10),
          _MetricValueRowSkeleton(),
          SizedBox(height: 8),
          _MetricValueRowSkeleton(),
        ],
      ),
    );
  }
}

class _MetricValueRowSkeleton extends StatelessWidget {
  const _MetricValueRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBlock(width: 6, height: 6, radius: 999),
        SizedBox(width: 6),
        Expanded(child: SkeletonBlock(width: 82, height: 12)),
        SizedBox(width: 10),
        SkeletonBlock(width: 54, height: 13),
      ],
    );
  }
}

class _ResourceChartSkeleton extends StatelessWidget {
  const _ResourceChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBlock(width: 160, height: 24),
          SizedBox(height: 14),
          Wrap(
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
          SizedBox(height: 18),
          SkeletonBlock(width: double.infinity, height: 180, radius: 18),
          SizedBox(height: 16),
          _StatsRowSkeleton(),
        ],
      ),
    );
  }
}

class _BandwidthChartSkeleton extends StatelessWidget {
  const _BandwidthChartSkeleton();

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

class _UptimeSkeleton extends StatelessWidget {
  const _UptimeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 230, height: 24),
          SizedBox(height: 10),
          SkeletonBlock(width: 210, height: 13),
          SizedBox(height: 18),
          SkeletonBlock(width: double.infinity, height: 140, radius: 18),
          SizedBox(height: 14),
          _StatsRowSkeleton(),
        ],
      ),
    );
  }
}

class _SnmpHealthSkeleton extends StatelessWidget {
  const _SnmpHealthSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 120, height: 24),
          SizedBox(height: 16),
          _SnmpRowSkeleton(),
          SizedBox(height: 12),
          _SnmpRowSkeleton(),
          SizedBox(height: 16),
          Divider(color: AppColors.stroke, height: 1),
          SizedBox(height: 14),
          Row(
            children: [
              SkeletonBlock(width: 18, height: 18, radius: 999),
              SizedBox(width: 8),
              Expanded(
                child: SkeletonBlock(width: double.infinity, height: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnmpRowSkeleton extends StatelessWidget {
  const _SnmpRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: const [
          SkeletonBlock(width: 8, height: 8, radius: 999),
          SizedBox(width: 10),
          Expanded(child: SkeletonBlock(width: 120, height: 14)),
          SizedBox(width: 12),
          SkeletonBlock(width: 58, height: 34, radius: 10),
          SizedBox(width: 8),
          SkeletonBlock(width: 58, height: 34, radius: 10),
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

class _SkeletonFilterDelegate extends SliverPersistentHeaderDelegate {
  const _SkeletonFilterDelegate({required this.padding});

  final double padding;

  static const double _verticalPadding = 12.0;
  static const double _filterHeight = 42.0;

  @override
  double get minExtent => _filterHeight + _verticalPadding * 2;

  @override
  double get maxExtent => _filterHeight + _verticalPadding * 2;

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
        child: const Align(
          alignment: Alignment.centerLeft,
          child: _FilterSkeleton(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SkeletonFilterDelegate oldDelegate) =>
      oldDelegate.padding != padding;
}
