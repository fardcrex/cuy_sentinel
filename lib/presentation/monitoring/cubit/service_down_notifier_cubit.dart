import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../../feature/monitoring/domain/entities/service_event.dart';
import 'service_down_notifier_state.dart';

class ServiceDownNotifierCubit extends Cubit<ServiceDownNotifierState> {
  ServiceDownNotifierCubit({required WatchActiveEventsUseCase watchEvents})
    : _watchEvents = watchEvents,
      super(ServiceDownNotifierIdle());

  final WatchActiveEventsUseCase _watchEvents;
  StreamSubscription<List<ServiceEvent>>? _sub;

  // IDs de eventos 'down' ya notificados para no repetir el dialog.
  final _notifiedIds = <String>{};

  void start() {
    if (_sub != null) return;
    _sub = _watchEvents.execute().listen(_onEvents, onError: (_) {});
  }

  void _onEvents(List<ServiceEvent> events) {
    for (final event in events) {
      if (event.eventType != ServiceEventType.down) continue;
      if (_notifiedIds.contains(event.id)) continue;
      _notifiedIds.add(event.id);
      emit(ServiceDownNotifierNewEvent(event));
    }
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _notifiedIds.clear();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
