import '../../../feature/monitoring/domain/entities/service_event.dart';

sealed class ServiceDownNotifierState {}

final class ServiceDownNotifierIdle extends ServiceDownNotifierState {}

final class ServiceDownNotifierNewEvent extends ServiceDownNotifierState {
  ServiceDownNotifierNewEvent(this.event);
  final ServiceEvent event;
}
