import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cuy_sentinel/core/widgets/alert_notification_dialog.dart';
import 'package:cuy_sentinel/feature/alerts/domain/entities/alert_event.dart';
import 'package:cuy_sentinel/feature/alerts/domain/entities/alert_severity.dart';

AlertEvent _alert({
  required String id,
  required String serviceName,
  required String metricName,
  required double currentValue,
}) => AlertEvent(
  id: id,
  serviceId: 'svc-$id',
  serviceName: serviceName,
  metricName: metricName,
  currentValue: currentValue,
  thresholdValue: 80,
  severity: AlertSeverity.info,
  triggeredAt: DateTime(2026, 5, 23, 12),
);

void main() {
  testWidgets('updates visible content when alert listenable changes', (
    tester,
  ) async {
    final first = _alert(
      id: '1',
      serviceName: 'Passbolt',
      metricName: 'CPU',
      currentValue: 91,
    );
    final second = _alert(
      id: '2',
      serviceName: 'ChkMonitor',
      metricName: 'RAM',
      currentValue: 87,
    );
    final currentAlert = ValueNotifier<AlertEvent?>(first);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAlertNotificationDialog(
              context,
              first,
              eventListenable: currentAlert,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Passbolt'), findsOneWidget);
    expect(find.text('CPU: 91.0'), findsOneWidget);

    currentAlert.value = second;
    await tester.pump();

    expect(find.text('ChkMonitor'), findsOneWidget);
    expect(find.text('RAM: 87.0'), findsOneWidget);
    expect(find.text('Passbolt'), findsNothing);

    currentAlert.dispose();
  });
}
