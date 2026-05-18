import 'dart:math' as math;

import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';
import '../../monitoring/domain/entities/service_status.dart';

class InMemoryMetricsRepository implements IMetricsRepository {
  static const _passboltId = 'svc-passbolt';
  static const _chkmonitorId = 'svc-chkmonitor';

  // Base values matching the UI seed data
  static const _base = {
    _passboltId: _BaseMetric(
      cpu: 45.0, ram: 612, ramTotal: 2048,
      disk: 58.0, bwIn: 2.3, bwOut: 1.1,
      uptime: 302063, latency: 28,
    ),
    _chkmonitorId: _BaseMetric(
      cpu: 12.0, ram: 256, ramTotal: 1024,
      disk: 44.0, bwIn: 0.8, bwOut: 0.4,
      uptime: 302063, latency: 22,
    ),
  };

  @override
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  }) async* {
    final rng = math.Random(serviceId.hashCode);
    var tick = 0;
    while (true) {
      yield _generate(serviceId, tick, rng, limit);
      tick++;
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  @override
  Future<List<Metric>> getByRange({
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rng = math.Random(serviceId.hashCode ^ from.millisecondsSinceEpoch);
    final diffMin = to.difference(from).inMinutes;
    final count = (diffMin / 5).ceil().clamp(1, 500);
    return List.generate(count, (i) {
      final t = from.add(Duration(minutes: i * 5));
      return _buildMetric(serviceId, i, rng, t);
    });
  }

  static List<Metric> _generate(
    String serviceId,
    int tick,
    math.Random rng,
    int limit,
  ) {
    final now = DateTime.now();
    return List.generate(limit.clamp(1, 50), (i) {
      final t = now.subtract(Duration(minutes: i * 5));
      return _buildMetric(serviceId, tick + i, rng, t);
    });
  }

  static Metric _buildMetric(
    String serviceId,
    int seed,
    math.Random rng,
    DateTime t,
  ) {
    final b = _base[serviceId] ?? _base[_passboltId]!;
    double jitter(double base, double range) =>
        (base + (rng.nextDouble() - 0.5) * range).clamp(0, 100);
    int jitterInt(int base, int range) =>
        (base + rng.nextInt(range * 2 + 1) - range).clamp(0, 1 << 30);

    return Metric(
      id: 'demo-$serviceId-$seed',
      serviceId: serviceId,
      cpuUsagePercent: jitter(b.cpu, 6.0),
      ramUsageMb: jitterInt(b.ram, 30),
      ramTotalMb: b.ramTotal,
      diskUsagePercent: jitter(b.disk, 2.0),
      bandwidthInMb: double.parse(
        (b.bwIn + (rng.nextDouble() - 0.5) * 0.4).clamp(0, 100).toStringAsFixed(2),
      ),
      bandwidthOutMb: double.parse(
        (b.bwOut + (rng.nextDouble() - 0.5) * 0.2).clamp(0, 100).toStringAsFixed(2),
      ),
      uptimeSeconds: b.uptime + seed * 300,
      serviceStatus: ServiceStatus.online,
      snmpLatencyMs: jitterInt(b.latency, 8),
      collectedAt: t,
    );
  }
}

class _BaseMetric {
  const _BaseMetric({
    required this.cpu,
    required this.ram,
    required this.ramTotal,
    required this.disk,
    required this.bwIn,
    required this.bwOut,
    required this.uptime,
    required this.latency,
  });

  final double cpu;
  final int ram;
  final int ramTotal;
  final double disk;
  final double bwIn;
  final double bwOut;
  final int uptime;
  final int latency;
}
