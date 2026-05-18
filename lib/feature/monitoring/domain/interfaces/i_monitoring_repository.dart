import '../entities/monitored_service.dart';

abstract interface class IMonitoringRepository {
  Future<List<MonitoredService>> getServices();
}
