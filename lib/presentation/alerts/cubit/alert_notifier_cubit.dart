import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/entities/alert_event.dart';
import 'alert_notifier_state.dart';

class AlertNotifierCubit extends Cubit<AlertNotifierState> {
  AlertNotifierCubit({
    required WatchAlertInsertsUseCase watchAlertInserts,
    required GetAlertsSinceUseCase getAlertsSince,
  }) : _watchAlertInserts = watchAlertInserts,
       _getAlertsSince = getAlertsSince,
       super(const AlertNotifierIdle());

  final WatchAlertInsertsUseCase _watchAlertInserts;
  final GetAlertsSinceUseCase _getAlertsSince;
  StreamSubscription<AlertEvent>? _sub;

  // Timestamp del último evento recibido. Se actualiza con cada INSERT que
  // llega. Al reconectar, el catchup busca alertas después de este instante.
  DateTime _lastSeenAt = DateTime.now();

  void start() {
    if (_sub != null) return;
    _lastSeenAt = DateTime.now();
    _sub = _watchAlertInserts.execute(
      onSubscribed: _catchUpMissedAlerts,
    ).listen(
      (alert) {
        _lastSeenAt = alert.triggeredAt;
        emit(AlertNotifierNewAlert(alert));
      },
      onError: (_) {},
    );
  }

  // Busca alertas disparadas después de _lastSeenAt y las emite en orden
  // cronológico, simulando la llegada natural de cada notificación.
  Future<void> _catchUpMissedAlerts() async {
    final missed = await _getAlertsSince.execute(_lastSeenAt);
    for (final alert in missed) {
      if (isClosed) return;
      _lastSeenAt = alert.triggeredAt;
      emit(AlertNotifierNewAlert(alert));
    }
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
