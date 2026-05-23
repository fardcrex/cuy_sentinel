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
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final cols = isMobile ? 2 : AppBreakpoints.metricsColumns(width);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: width >= 900
              ? 1.5
              : isMobile
              ? 0.9
              : 1.3,
          children: cards
              .map((card) => MetricSummaryCard(model: card, compact: isMobile))
              .toList(),
        );
      },
    );
  }
}

class MetricSummaryCard extends StatelessWidget {
  const MetricSummaryCard({
    super.key,
    required this.model,
    this.compact = false,
  });

  final MetricSummaryCardModel model;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 32 : 36,
                height: compact ? 32 : 36,
                decoration: BoxDecoration(
                  color: model.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(compact ? 9 : 10),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: compact ? 12 : null,
              height: compact ? 1.1 : null,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          MetricServiceValueRow(
            name: 'Passbolt',
            value: model.passboltValue,
            color: model.color,
            compact: compact,
          ),
          SizedBox(height: compact ? 4 : 6),
          MetricServiceValueRow(
            name: 'ChkMonitor',
            value: model.chkmonitorValue,
            color: model.color.withValues(alpha: 0.7),
            compact: compact,
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
    this.compact = false,
  });

  final String name;
  final Widget value;
  final Color color;
  final bool compact;

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                color: color,
                fontWeight: FontWeight.w700,
              ),
              child: value,
            ),
          ),
        ),
      ],
    );
  }
}
