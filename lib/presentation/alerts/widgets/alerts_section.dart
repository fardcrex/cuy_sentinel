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
    required this.isResolved,
    required this.isDismissing,
    required this.canResolveAlerts,
    this.onViewAll,
  });

  final List<AlertEventModel> alerts;
  final bool Function(String alertId) isResolving;
  final bool Function(String alertId) isResolved;
  final bool Function(String alertId) isDismissing;
  final bool canResolveAlerts;
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
            return _AnimatedAlertItem(
              isDismissing: isDismissing(alert.id),
              bottomPadding: index < alerts.length - 1 ? 12 : 0,
              child: AlertThresholdTile(
                service: alert.service,
                metric: alert.metric,
                currentValue: alert.currentValue,
                threshold: alert.threshold,
                severity: alert.severity,
                timestamp: alert.timestamp,
                isResolving: isResolving(alert.id),
                isResolved: isResolved(alert.id),
                onResolve: canResolveAlerts
                    ? () => context.read<AlertsCubit>().resolveAlert(alert.id)
                    : null,
              ),
            );
          }),
      ],
    );
  }
}

class _AnimatedAlertItem extends StatelessWidget {
  const _AnimatedAlertItem({
    required this.child,
    required this.isDismissing,
    required this.bottomPadding,
  });

  final Widget child;
  final bool isDismissing;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isDismissing ? 0 : 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      builder: (context, factor, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: factor,
            child: Opacity(
              opacity: factor,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
