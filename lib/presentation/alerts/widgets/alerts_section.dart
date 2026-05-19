import 'package:flutter/material.dart';

import '../../widgets/alert_threshold_tile.dart';
import '../alert_model.dart';
import 'empty_state.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key, required this.alerts});

  final List<AlertEventModel> alerts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas activas',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        if (alerts.isEmpty)
          const AlertEmptyState(message: 'Sin alertas activas')
        else
          ...List.generate(alerts.length, (index) {
            final alert = alerts[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < alerts.length - 1 ? 12 : 0),
              child: AlertThresholdTile(
                service: alert.service,
                metric: alert.metric,
                currentValue: alert.currentValue,
                threshold: alert.threshold,
                severity: alert.severity,
                timestamp: alert.timestamp,
              ),
            );
          }),
      ],
    );
  }
}
