import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_skeleton.dart';

class UsersLoadingView extends StatelessWidget {
  const UsersLoadingView({super.key});

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
            padding: EdgeInsets.fromLTRB(
              padding,
              padding,
              padding,
              padding + bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _UsersHeaderSkeleton(),
                const SizedBox(height: 24),
                if (isWide)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _UsersListSkeleton()),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _SessionStatsSkeleton(),
                            SizedBox(height: 20),
                            _AccessLogSkeleton(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const Column(
                    children: [
                      _SessionStatsSkeleton(),
                      SizedBox(height: 20),
                      _UsersListSkeleton(),
                      SizedBox(height: 20),
                      _AccessLogSkeleton(),
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

class _UsersHeaderSkeleton extends StatelessWidget {
  const _UsersHeaderSkeleton();

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
            SkeletonBlock(width: 160, height: 32),
            SizedBox(height: 10),
            SkeletonBlock(width: 260, height: 16),
          ],
        ),
        SkeletonBlock(width: 118, height: 34, radius: 999),
      ],
    );
  }
}

class _SessionStatsSkeleton extends StatelessWidget {
  const _SessionStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 190, height: 24),
          SizedBox(height: 22),
          _StatRowSkeleton(),
          SizedBox(height: 16),
          _StatRowSkeleton(),
          SizedBox(height: 16),
          _StatRowSkeleton(),
          SizedBox(height: 16),
          _StatRowSkeleton(),
          SizedBox(height: 22),
          SkeletonBlock(width: double.infinity, height: 66, radius: 16),
        ],
      ),
    );
  }
}

class _UsersListSkeleton extends StatelessWidget {
  const _UsersListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < 3 ? 12 : 0),
          child: const _UserTileSkeleton(),
        ),
      ),
    );
  }
}

class _AccessLogSkeleton extends StatelessWidget {
  const _AccessLogSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 170, height: 24),
          SizedBox(height: 18),
          _LogEntrySkeleton(width: 180),
          SizedBox(height: 14),
          _LogEntrySkeleton(width: 220),
          SizedBox(height: 14),
          _LogEntrySkeleton(width: 150),
          SizedBox(height: 14),
          _LogEntrySkeleton(width: 200),
        ],
      ),
    );
  }
}

class _UserTileSkeleton extends StatelessWidget {
  const _UserTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: const Row(
        children: [
          SkeletonBlock(width: 44, height: 44, radius: 999),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 180, height: 16),
                SizedBox(height: 8),
                SkeletonBlock(width: 110, height: 12),
              ],
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBlock(width: 86, height: 24, radius: 999),
              SizedBox(height: 8),
              SkeletonBlock(width: 58, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRowSkeleton extends StatelessWidget {
  const _StatRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBlock(width: 16, height: 16, radius: 999),
        SizedBox(width: 10),
        Expanded(child: SkeletonBlock(width: double.infinity, height: 14)),
        SizedBox(width: 20),
        SkeletonBlock(width: 34, height: 16),
      ],
    );
  }
}

class _LogEntrySkeleton extends StatelessWidget {
  const _LogEntrySkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBlock(width: 6, height: 6, radius: 999),
        const SizedBox(width: 10),
        Expanded(child: SkeletonBlock(width: width, height: 13)),
        const SizedBox(width: 16),
        const SkeletonBlock(width: 54, height: 11),
      ],
    );
  }
}
