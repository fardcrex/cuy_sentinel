import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../metric_model.dart';

class MetricsSummaryGrid extends StatelessWidget {
  const MetricsSummaryGrid({super.key, required this.cards});

  final List<MetricSummaryCardModel> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = AppBreakpoints.metricsColumns(constraints.maxWidth);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth >= 900 ? 1.5 : 1.3,
          children: cards
              .map((card) => MetricSummaryCard(model: card))
              .toList(),
        );
      },
    );
  }
}

class MetricSummaryCard extends StatelessWidget {
  const MetricSummaryCard({super.key, required this.model});

  final MetricSummaryCardModel model;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: model.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(model.icon, color: model.color, size: 18),
              ),
              const Spacer(),
              StatusBadge(status: model.status, compact: true),
            ],
          ),
          const Spacer(),
          Text(
            model.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          MetricServiceValueRow(
            name: 'Passbolt',
            value: model.passboltValue,
            color: model.color,
          ),
          const SizedBox(height: 6),
          MetricServiceValueRow(
            name: 'ChkMonitor',
            value: model.chkmonitorValue,
            color: model.color.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class MetricServiceValueRow extends StatelessWidget {
  const MetricServiceValueRow({
    super.key,
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final Widget value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
          child: value,
        ),
      ],
    );
  }
}
