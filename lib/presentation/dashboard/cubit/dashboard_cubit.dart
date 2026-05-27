import 'dart:async';
import 'dart:developer';

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
    required WatchActiveEventsUseCase watchServiceEvents,
  }) : _watchMetrics = watchMetrics,
       _watchAlerts = watchAlerts,
       _getCollectorRuns = getCollectorRuns,
       _watchLastCollectorRun = watchLastCollectorRun,
       _getServices = getServices,
       _getServiceEvents = getServiceEvents,
       _watchServiceEvents = watchServiceEvents,
       super(DashboardInitial());

  final WatchLatestMetricsUseCase _watchMetrics;
  final WatchActiveAlertsUseCase _watchAlerts;
  final GetCollectorRunsUseCase _getCollectorRuns;
  final WatchLastCollectorRunUseCase _watchLastCollectorRun;
  final GetServicesUseCase _getServices;
  final GetServiceEventsUseCase _getServiceEvents;
  final WatchActiveEventsUseCase _watchServiceEvents;

  StreamSubscription<List<Metric>>? _passboltSub;
  StreamSubscription<List<Metric>>? _chkmonitorSub;
  StreamSubscription<List<AlertEvent>>? _alertsSub;
  StreamSubscription<CollectorRun?>? _collectorRunSub;
  StreamSubscription<List<ServiceEvent>>? _serviceEventsSub;

  bool _isActive = false;
  bool _passboltReady = false;
  bool _chkmonitorReady = false;

  List<Metric> _passboltMetrics = [];
  List<Metric> _chkmonitorMetrics = [];
  List<AlertEvent> _activeAlerts = [];
  List<CollectorRun> _collectorRuns = [];
  List<MonitoredService> _services = [];
  List<ServiceEvent> _recentEvents = [];
  List<ServiceEvent> _activeServiceEvents = [];

  Future<void> init() => activate();

  Future<void> activate() async {
    _isActive = true;
    if (_passboltSub != null ||
        _chkmonitorSub != null ||
        _alertsSub != null ||
        _collectorRunSub != null) {
      return;
    }

    if (_services.isEmpty) {
      emit(DashboardLoading());
      try {
        _collectorRuns = await _getCollectorRuns.execute(limit: 150);
        _services = await _getServices.execute();
        // Load initial snapshot of recent events (historical, includes resolved).
        _recentEvents = await _loadRecentEvents(_services);
      } catch (e, st) {
        log(
          'Error en dashboard.init',
          error: e,
          stackTrace: st,
          name: 'DashboardCubit',
        );
        emit(DashboardError(e.toString(), source: 'dashboard.init'));
        return;
      }
      if (!_isActive || isClosed) return;
    }

    final passboltId = _services
        .firstWhere((s) => s.slug == 'passbolt', orElse: () => _services.first)
        .id;
    final chkmonitorId = _services
        .firstWhere((s) => s.slug == 'chkmonitor', orElse: () => _services.last)
        .id;

    _passboltSub = _watchMetrics
        .execute(serviceId: passboltId, limit: 12)
        .listen(
          (m) {
            if (!_isActive) return;
            _passboltMetrics = m;
            _passboltReady = true;
            _emitLoaded();
          },
          onError: (e, st) {
            log(
              'Error en passbolt.metrics',
              error: e,
              stackTrace: st,
              name: 'DashboardCubit',
            );
            emit(DashboardError(e.toString(), source: 'passbolt.metrics'));
          },
        );
    _chkmonitorSub = _watchMetrics
        .execute(serviceId: chkmonitorId, limit: 12)
        .listen(
          (m) {
            if (!_isActive) return;
            _chkmonitorMetrics = m;
            _chkmonitorReady = true;
            _emitLoaded();
          },
          onError: (e, st) {
            log(
              'Error en chkmonitor.metrics',
              error: e,
              stackTrace: st,
              name: 'DashboardCubit',
            );
            emit(DashboardError(e.toString(), source: 'chkmonitor.metrics'));
          },
        );
    _alertsSub = _watchAlerts.execute().listen(
      (a) {
        if (!_isActive) return;
        _activeAlerts = a;
        _emitLoaded();
      },
      onError: (e, st) {
        log(
          'Error en alerts',
          error: e,
          stackTrace: st,
          name: 'DashboardCubit',
        );
        emit(DashboardError(e.toString(), source: 'alerts'));
      },
    );
    _collectorRunSub = _watchLastCollectorRun.execute().listen(
      (run) {
        if (!_isActive) return;
        if (run == null) return;
        _collectorRuns = _upsertCollectorRun(_collectorRuns, run, 150);
        _emitLoaded();
      },
      onError: (e, st) {
        log(
          'Error en collector_run',
          error: e,
          stackTrace: st,
          name: 'DashboardCubit',
        );
        emit(DashboardError(e.toString(), source: 'collector_run'));
      },
    );

    // Real-time active events: drives ServicesStatusCard status and merges
    // new events into the historical RecentEventsCard list.
    _serviceEventsSub = _watchServiceEvents.execute().listen(
      (events) {
        if (!_isActive) return;
        _activeServiceEvents = events;
        _mergeIntoRecentEvents(events);
        _emitLoaded();
      },
      onError: (e, st) {
        log(
          'Error en service_events',
          error: e,
          stackTrace: st,
          name: 'DashboardCubit',
        );
      },
    );

    _emitLoaded();
  }

  Future<void> refresh() async {
    final current = state;
    if (current is DashboardLoaded) emit(current.asRefreshing());

    await deactivate();
    _passboltReady = false;
    _chkmonitorReady = false;
    _passboltMetrics = [];
    _chkmonitorMetrics = [];
    _activeAlerts = [];
    _collectorRuns = [];
    _services = [];
    _recentEvents = [];
    _activeServiceEvents = [];

    await activate();
  }

  Future<void> deactivate() async {
    _isActive = false;
    await _passboltSub?.cancel();
    await _chkmonitorSub?.cancel();
    await _alertsSub?.cancel();
    await _collectorRunSub?.cancel();
    await _serviceEventsSub?.cancel();
    _passboltSub = null;
    _chkmonitorSub = null;
    _alertsSub = null;
    _collectorRunSub = null;
    _serviceEventsSub = null;
  }

  void _emitLoaded() {
    if (!_passboltReady || !_chkmonitorReady) return;
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
      activeServiceEvents: _activeServiceEvents,
    ),
  );

  /// Merges newly detected active events into [_recentEvents] so the
  /// RecentEventsCard stays up-to-date without a full reload.
  void _mergeIntoRecentEvents(List<ServiceEvent> incoming) {
    final existing = {for (final e in _recentEvents) e.id};
    final novel = incoming.where((e) => !existing.contains(e.id)).toList();
    if (novel.isEmpty) return;
    _recentEvents = [...novel, ..._recentEvents]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_recentEvents.length > 5) _recentEvents = _recentEvents.take(5).toList();
  }

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
  Future<void> close() async {
    await deactivate();
    return super.close();
  }
}
