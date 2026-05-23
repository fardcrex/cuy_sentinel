import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/alert_threshold_tile.dart';
import '../alert_model.dart';
import '../cubit/alerts_cubit.dart';
import 'empty_state.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({
    super.key,
    required this.alerts,
    required this.isResolving,
    this.onViewAll,
  });

  final List<AlertEventModel> alerts;
  final bool Function(String alertId) isResolving;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Alertas activas',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 14),
        if (alerts.isEmpty)
          const AlertEmptyState(message: 'Sin alertas activas')
        else
          ...List.generate(alerts.length, (index) {
            final alert = alerts[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < alerts.length - 1 ? 12 : 0,
              ),
              child: AlertThresholdTile(
                service: alert.service,
                metric: alert.metric,
                currentValue: alert.currentValue,
                threshold: alert.threshold,
                severity: alert.severity,
                timestamp: alert.timestamp,
                isResolving: isResolving(alert.id),
                onResolve: () =>
                    context.read<AlertsCubit>().resolveAlert(alert.id),
              ),
            );
          }),
      ],
    );
  }
}
