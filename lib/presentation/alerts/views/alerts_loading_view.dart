import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_skeleton.dart';

class AlertsLoadingView extends StatelessWidget {
  const AlertsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = AppBreakpoints.isDesktop(width);

        return LoadingSkeletonPulse(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AlertsHeaderSkeleton(),
                const SizedBox(height: 24),
                if (isWide)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _AlertsSectionSkeleton(),
                            SizedBox(height: 24),
                            _IncidentsSectionSkeleton(),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(flex: 2, child: _AlertsAsideSkeleton()),
                    ],
                  )
                else
                  const Column(
                    children: [
                      _AlertsAsideSkeleton(),
                      SizedBox(height: 24),
                      _AlertsSectionSkeleton(),
                      SizedBox(height: 24),
                      _IncidentsSectionSkeleton(),
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

class _AlertsHeaderSkeleton extends StatelessWidget {
  const _AlertsHeaderSkeleton();

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
            SkeletonBlock(width: 150, height: 32),
            SizedBox(height: 10),
            SkeletonBlock(width: 260, height: 16),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SkeletonBlock(width: 86, height: 30, radius: 999),
            SkeletonBlock(width: 112, height: 30, radius: 999),
            SkeletonBlock(width: 96, height: 30, radius: 999),
          ],
        ),
      ],
    );
  }
}

class _AlertsAsideSkeleton extends StatelessWidget {
  const _AlertsAsideSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AppCard(
          child: Column(
            children: [
              SkeletonBlock(width: 160, height: 160, radius: 80),
              SizedBox(height: 16),
              SkeletonBlock(width: double.infinity, height: 14),
              SizedBox(height: 10),
              SkeletonBlock(width: 260, height: 14),
              SizedBox(height: 10),
              SkeletonBlock(width: 210, height: 14),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBlock(width: 18, height: 18, radius: 999),
                  SizedBox(width: 8),
                  SkeletonBlock(width: 180, height: 18),
                ],
              ),
              SizedBox(height: 16),
              _ThresholdRowSkeleton(width: 90),
              SizedBox(height: 12),
              _ThresholdRowSkeleton(width: 120),
              SizedBox(height: 12),
              _ThresholdRowSkeleton(width: 100),
              SizedBox(height: 12),
              _ThresholdRowSkeleton(width: 110),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertsSectionSkeleton extends StatelessWidget {
  const _AlertsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SkeletonBlock(width: 180, height: 24)),
            SkeletonBlock(width: 72, height: 34, radius: 999),
          ],
        ),
        SizedBox(height: 14),
        _AlertTileSkeleton(),
        SizedBox(height: 12),
        _AlertTileSkeleton(),
        SizedBox(height: 12),
        _AlertTileSkeleton(),
      ],
    );
  }
}

class _IncidentsSectionSkeleton extends StatelessWidget {
  const _IncidentsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 220, height: 24),
        SizedBox(height: 14),
        _IncidentTileSkeleton(),
        SizedBox(height: 12),
        _IncidentTileSkeleton(),
        SizedBox(height: 12),
        _IncidentTileSkeleton(),
      ],
    );
  }
}

class _AlertTileSkeleton extends StatelessWidget {
  const _AlertTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          SkeletonBlock(width: 42, height: 42, radius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 190, height: 16),
                SizedBox(height: 8),
                SkeletonBlock(width: 130, height: 12),
              ],
            ),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBlock(width: 78, height: 24, radius: 999),
              SizedBox(height: 8),
              SkeletonBlock(width: 62, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentTileSkeleton extends StatelessWidget {
  const _IncidentTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBlock(width: 38, height: 38, radius: 12),
              SizedBox(width: 12),
              Expanded(child: SkeletonBlock(width: 210, height: 16)),
              SizedBox(width: 12),
              SkeletonBlock(width: 82, height: 24, radius: 999),
            ],
          ),
          SizedBox(height: 14),
          SkeletonBlock(width: double.infinity, height: 12),
          SizedBox(height: 8),
          SkeletonBlock(width: 260, height: 12),
        ],
      ),
    );
  }
}

class _ThresholdRowSkeleton extends StatelessWidget {
  const _ThresholdRowSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBlock(width: 8, height: 8, radius: 999),
        const SizedBox(width: 10),
        Expanded(child: SkeletonBlock(width: width, height: 13)),
        const SizedBox(width: 16),
        const SkeletonBlock(width: 48, height: 16),
      ],
    );
  }
}
