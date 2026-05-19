import '../../../../feature/monitoring/domain/entities/collector_run.dart';
import '../../../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../../../feature/monitoring/domain/entities/service_event.dart';

sealed class ServicesState {}

final class ServicesInitial extends ServicesState {}

final class ServicesLoading extends ServicesState {}

final class ServicesLoaded extends ServicesState {
  ServicesLoaded({
    required this.services,
    required this.activeEvents,
    this.lastRun,
  });

  final List<MonitoredService> services;
  final List<ServiceEvent> activeEvents;
  final CollectorRun? lastRun;
}

final class ServicesError extends ServicesState {
  ServicesError(this.message);
  final String message;
}
