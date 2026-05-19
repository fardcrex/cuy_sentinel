import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../alert_model.dart';
import 'threshold_row.dart';

class AlertsAside extends StatelessWidget {
  const AlertsAside({super.key, required this.thresholds});

  final List<AlertThresholdModel> thresholds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              Image.asset(AppAssets.badgeAlertWarning, width: 160, height: 160),
              const SizedBox(height: 12),
              Text(
                'Las alertas se derivan automáticamente al superar los umbrales '
                'definidos sobre las métricas SNMP recolectadas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Umbrales configurados',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...List.generate(thresholds.length, (index) {
                final threshold = thresholds[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < thresholds.length - 1 ? 8 : 0,
                  ),
                  child: AlertThresholdRow(
                    metric: threshold.metric,
                    threshold: threshold.threshold,
                    color: threshold.color,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
