import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/entities/alert_event.dart';
import 'alert_notifier_state.dart';

class AlertNotifierCubit extends Cubit<AlertNotifierState> {
  AlertNotifierCubit({required WatchActiveAlertsUseCase watchAlerts})
    : _watchAlerts = watchAlerts,
      super(const AlertNotifierIdle());

  final WatchActiveAlertsUseCase _watchAlerts;
  StreamSubscription<List<AlertEvent>>? _sub;
  final _knownIds = <String>{};
  bool _initialized = false;

  void init() {
    _sub = _watchAlerts.execute().listen(
      (alerts) {
        if (!_initialized) {
          _knownIds.addAll(alerts.map((a) => a.id));
          _initialized = true;
          return;
        }
        for (final alert in alerts) {
          if (_knownIds.add(alert.id)) {
            emit(AlertNotifierNewAlert(alert));
          }
        }
      },
      onError: (_) {},
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
