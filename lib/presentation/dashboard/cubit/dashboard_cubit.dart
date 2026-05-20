import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/alerts/application/get_alerts_use_case.dart';
import '../../../feature/alerts/domain/entities/alert_event.dart';
import '../../../feature/metrics/application/get_latest_metrics_use_case.dart';
import '../../../feature/metrics/domain/entities/metric.dart';
import '../../../feature/monitoring/application/get_collector_runs_use_case.dart';
import '../../../feature/monitoring/application/get_service_events_use_case.dart';
import '../../../feature/monitoring/application/get_services_use_case.dart';
import '../../../feature/monitoring/domain/entities/collector_run.dart';
import '../../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../../feature/monitoring/domain/entities/service_event.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required WatchLatestMetricsUseCase watchMetrics,
    required WatchActiveAlertsUseCase watchAlerts,
    required GetCollectorRunsUseCase getCollectorRuns,
    required WatchLastCollectorRunUseCase watchLastCollectorRun,
    required GetServicesUseCase getServices,
    required GetServiceEventsUseCase getServiceEvents,
  }) : _watchMetrics = watchMetrics,
       _watchAlerts = watchAlerts,
       _getCollectorRuns = getCollectorRuns,
       _watchLastCollectorRun = watchLastCollectorRun,
       _getServices = getServices,
       _getServiceEvents = getServiceEvents,
       super(DashboardInitial());

  final WatchLatestMetricsUseCase _watchMetrics;
  final WatchActiveAlertsUseCase _watchAlerts;
  final GetCollectorRunsUseCase _getCollectorRuns;
  final WatchLastCollectorRunUseCase _watchLastCollectorRun;
  final GetServicesUseCase _getServices;
  final GetServiceEventsUseCase _getServiceEvents;

  StreamSubscription<List<Metric>>? _passboltSub;
  StreamSubscription<List<Metric>>? _chkmonitorSub;
  StreamSubscription<List<AlertEvent>>? _alertsSub;
  StreamSubscription<CollectorRun?>? _collectorRunSub;

  List<Metric> _passboltMetrics = [];
  List<Metric> _chkmonitorMetrics = [];
  List<AlertEvent> _activeAlerts = [];
  List<CollectorRun> _collectorRuns = [];
  List<MonitoredService> _services = [];
  List<ServiceEvent> _recentEvents = [];

  Future<void> init() async {
    emit(DashboardLoading());
    try {
      _collectorRuns = await _getCollectorRuns.execute(limit: 150);
      _services = await _getServices.execute();
      _recentEvents = await _loadRecentEvents(_services);
    } catch (e) {
      emit(DashboardError(e.toString()));
      return;
    }

    final passboltId = _services
        .firstWhere((s) => s.slug == 'passbolt', orElse: () => _services.first)
        .id;
    final chkmonitorId = _services
        .firstWhere((s) => s.slug == 'chkmonitor', orElse: () => _services.last)
        .id;

    _passboltSub = _watchMetrics
        .execute(serviceId: passboltId, limit: 12)
        .listen((m) {
          _passboltMetrics = m;
          _emitLoaded();
        }, onError: (e) => emit(DashboardError(e.toString())));
    _chkmonitorSub = _watchMetrics
        .execute(serviceId: chkmonitorId, limit: 12)
        .listen((m) {
          _chkmonitorMetrics = m;
          _emitLoaded();
        }, onError: (e) => emit(DashboardError(e.toString())));
    _alertsSub = _watchAlerts.execute().listen((a) {
      _activeAlerts = a;
      _emitLoaded();
    }, onError: (e) => emit(DashboardError(e.toString())));
    _collectorRunSub = _watchLastCollectorRun.execute().listen((run) {
      if (run == null) return;
      _collectorRuns = _upsertCollectorRun(_collectorRuns, run, 150);
      _emitLoaded();
    }, onError: (e) => emit(DashboardError(e.toString())));

    _emitLoaded();
  }

  void _emitLoaded() {
    if (_passboltMetrics.isEmpty || _chkmonitorMetrics.isEmpty) return;
    _doEmitLoaded();
  }

  void _doEmitLoaded() => emit(
    DashboardLoaded(
      passboltMetrics: _passboltMetrics,
      chkmonitorMetrics: _chkmonitorMetrics,
      activeAlerts: _activeAlerts,
      collectorRuns: _collectorRuns,
      services: _services,
      recentEvents: _recentEvents,
    ),
  );

  Future<List<ServiceEvent>> _loadRecentEvents(
    List<MonitoredService> services,
  ) async {
    final eventGroups = await Future.wait(
      services.map(
        (service) => _getServiceEvents.execute(serviceId: service.id, limit: 3),
      ),
    );

    final events = eventGroups.expand((group) => group).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events.take(3).toList();
  }

  List<CollectorRun> _upsertCollectorRun(
    List<CollectorRun> current,
    CollectorRun next,
    int limit,
  ) {
    final updated = current.where((run) => run.id != next.id).toList()
      ..insert(0, next)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    if (updated.length > limit) {
      return updated.take(limit).toList();
    }
    return updated;
  }

  @override
  Future<void> close() {
    _passboltSub?.cancel();
    _chkmonitorSub?.cancel();
    _alertsSub?.cancel();
    _collectorRunSub?.cancel();
    return super.close();
  }
}
