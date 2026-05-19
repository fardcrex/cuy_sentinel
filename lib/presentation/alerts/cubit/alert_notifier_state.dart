import '../../../feature/alerts/domain/entities/alert_event.dart';

abstract class AlertNotifierState {
  const AlertNotifierState();
}

class AlertNotifierIdle extends AlertNotifierState {
  const AlertNotifierIdle();
}

class AlertNotifierNewAlert extends AlertNotifierState {
  const AlertNotifierNewAlert(this.alert);
  final AlertEvent alert;
}
