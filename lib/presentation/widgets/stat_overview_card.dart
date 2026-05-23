import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_card.dart';
import 'sparkline.dart';

class StatOverviewCard extends StatelessWidget {
  const StatOverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    required this.sparkPoints,
    this.compact = false,
  });

  final String title;
  final Widget value;
  final Widget caption;
  final IconData icon;
  final Color color;
  final List<double> sparkPoints;
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
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(compact ? 10 : 12),
                ),
                child: Icon(icon, color: color, size: compact ? 18 : 20),
              ),
              const Spacer(),
              Sparkline(
                points: sparkPoints,
                color: color,
                width: compact ? 52 : 72,
                height: compact ? 24 : 28,
              ),
            ],
          ),
          const Spacer(),
          DefaultTextStyle(
            style:
                Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 28 : null,
                ) ??
                TextStyle(
                  color: color,
                  fontSize: compact ? 28 : null,
                  fontWeight: FontWeight.w800,
                ),
            child: value,
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : null,
              height: compact ? 1.1 : null,
            ),
          ),
          SizedBox(height: compact ? 1 : 2),
          DefaultTextStyle(
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: compact ? 11 : null,
                  height: compact ? 1.1 : null,
                ) ??
                TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: compact ? 11 : null,
                  height: compact ? 1.1 : null,
                ),
            child: caption,
          ),
        ],
      ),
    );
  }
}
