import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../../../feature/monitoring/application/get_services_use_case.dart';
import '../../../../feature/monitoring/domain/entities/collector_run.dart';
import '../../../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../../../feature/monitoring/domain/entities/service_event.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit({
    required GetServicesUseCase getServices,
    required WatchActiveEventsUseCase watchEvents,
    required WatchLastCollectorRunUseCase watchRun,
  })  : _getServices = getServices,
        _watchEvents = watchEvents,
        _watchRun = watchRun,
        super(ServicesInitial());

  final GetServicesUseCase _getServices;
  final WatchActiveEventsUseCase _watchEvents;
  final WatchLastCollectorRunUseCase _watchRun;

  StreamSubscription<List<ServiceEvent>>? _eventsSub;
  StreamSubscription<CollectorRun?>? _runSub;

  List<ServiceEvent> _activeEvents = [];
  CollectorRun? _lastRun;

  Future<void> load() async {
    emit(ServicesLoading());
    try {
      final services = await _getServices.execute();
      emit(ServicesLoaded(
        services: services,
        activeEvents: _activeEvents,
        lastRun: _lastRun,
      ));

      _eventsSub = _watchEvents.execute().listen((events) {
        _activeEvents = events;
        _emitLoaded(services);
      });

      _runSub = _watchRun.execute().listen((run) {
        _lastRun = run;
        _emitLoaded(services);
      });
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  void _emitLoaded(List<MonitoredService> services) => emit(ServicesLoaded(
        services: services,
        activeEvents: _activeEvents,
        lastRun: _lastRun,
      ));

  @override
  Future<void> close() {
    _eventsSub?.cancel();
    _runSub?.cancel();
    return super.close();
  }
}
