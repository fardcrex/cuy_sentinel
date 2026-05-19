import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AlertThresholdRow extends StatelessWidget {
  const AlertThresholdRow({
    super.key,
    required this.metric,
    required this.threshold,
    required this.color,
  });

  final String metric;
  final String threshold;
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            metric,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          threshold,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
