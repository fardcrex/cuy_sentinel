import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/stat_overview_card.dart';
import '../dashboard_model.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({super.key, required this.cards});

  final List<DashboardStatCardModel> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : AppBreakpoints.metricsColumns(width),
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: width >= 900
              ? 1.6
              : isMobile
              ? 0.95
              : 1.35,
          children: cards
              .map(
                (card) => StatOverviewCard(
                  title: card.title,
                  value: card.value,
                  caption: card.caption,
                  icon: card.icon,
                  color: card.color,
                  sparkPoints: card.sparkPoints,
                  compact: isMobile,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
