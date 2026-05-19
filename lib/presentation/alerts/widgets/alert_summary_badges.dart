import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../alert_model.dart';
import 'summary_badge.dart';

class AlertSummaryBadges extends StatelessWidget {
  const AlertSummaryBadges({super.key, required this.summary});

  final AlertsSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AlertSummaryBadge(label: summary.criticalLabel, color: AppColors.danger),
        AlertSummaryBadge(label: summary.warningLabel, color: AppColors.warning),
        AlertSummaryBadge(
          label: summary.closedTodayLabel,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
