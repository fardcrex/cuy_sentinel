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
  });

  final String title;
  final Widget value;
  final Widget caption;
  final IconData icon;
  final Color color;
  final List<double> sparkPoints;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Sparkline(
                points: sparkPoints,
                color: color,
                width: 72,
                height: 28,
              ),
            ],
          ),
          const Spacer(),
          DefaultTextStyle(
            style:
                Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ) ??
                TextStyle(color: color, fontWeight: FontWeight.w800),
            child: value,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          DefaultTextStyle(
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ) ??
                const TextStyle(color: AppColors.textSecondary),
            child: caption,
          ),
        ],
      ),
    );
  }
}
