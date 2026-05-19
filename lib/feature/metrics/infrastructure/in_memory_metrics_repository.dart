import 'dart:math' as math;

import '../../monitoring/domain/entities/service_status.dart';
import '../domain/entities/metric.dart';
import '../domain/interfaces/i_metrics_repository.dart';

class InMemoryMetricsRepository implements IMetricsRepository {
  static const _passboltId = 'svc-passbolt';
  static const _chkmonitorId = 'svc-chkmonitor';

  // Base values matching the UI seed data
  static const _base = {
    _passboltId: _BaseMetric(
      cpu: 45.0,
      ram: 612,
      ramTotal: 2048,
      disk: 58.0,
      bwIn: 2.3,
      bwOut: 1.1,
      uptime: 302063,
      latency: 28,
      lossBase: 0.3,
    ),
    _chkmonitorId: _BaseMetric(
      cpu: 12.0,
      ram: 256,
      ramTotal: 1024,
      disk: 44.0,
      bwIn: 0.8,
      bwOut: 0.4,
      uptime: 302063,
      latency: 22,
      lossBase: 0.05,
    ),
  };

  @override
  Stream<List<Metric>> watchLatest({
    required String serviceId,
    int limit = 50,
  }) async* {
    final rng = math.Random(serviceId.hashCode);
    final normalizedLimit = limit.clamp(1, 50);
    var tick = 0;
    var history = _generate(serviceId, tick, rng, normalizedLimit);
    yield history;
    tick += normalizedLimit;
    while (true) {
      final now = DateTime.now();
      final nextMetric = _buildMetric(serviceId, tick, rng, now);
      history = [nextMetric, ...history].take(normalizedLimit).toList();
      yield history;
      tick++;
      await Future.delayed(const Duration(seconds: 2));
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

    // Use coarser sampling for longer ranges so we stay under the 500-sample
    // cap and still cover the full window.
    // 7d → 30 min (336 pts), 24h → 10 min (144 pts), ≤6h → 5 min.
    final intervalMin = _samplingIntervalMin(diffMin);
    final count = (diffMin / intervalMin).ceil().clamp(1, 500);

    // 7d demo gap: skip [49 h, 108 h) from `from`.
    // bucketSize for 7d = 14 h, lookbackTolerance = 21 h.
    // B5 fallback window = [49 h, 70 h) → must be inside gap → gapStart ≤ 49 h.
    // B6 fallback window = [63 h, 84 h) → must be inside gap → already covered.
    // First sample after gap = 108 h → falls in B7 [98 h, 112 h) → B7 has data.
    final bool is7d = diffMin >= 7 * 24 * 60 - 60;
    final gapStart = is7d ? from.add(const Duration(hours: 49)) : null;
    final gapEnd   = is7d ? from.add(const Duration(hours: 108)) : null;

    final metrics = <Metric>[];
    for (var i = 0; i < count; i++) {
      final t = from.add(Duration(minutes: i * intervalMin));
      if (gapStart != null && !t.isBefore(gapStart) && t.isBefore(gapEnd!)) {
        continue;
      }
      metrics.add(_buildMetric(serviceId, i, rng, t));
    }
    return metrics;
  }

  static int _samplingIntervalMin(int diffMin) {
    if (diffMin >= 7 * 24 * 60) return 30;
    if (diffMin >= 24 * 60) return 10;
    return 5;
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
    final cpu = _clampDouble(
      b.cpu +
          _wave(seed, period: 10, amplitude: 6.5) +
          _wave(seed, period: 4, amplitude: 2.4, phase: 0.65) +
          _spike(seed, every: 13, width: 3, amplitude: 16) +
          _noise(rng, 2.0),
      0,
      100,
    );
    final ramUsage = _clampInt(
      b.ram +
          _wave(seed, period: 12, amplitude: 96).round() +
          _wave(seed, period: 5, amplitude: 40, phase: 0.35).round() +
          _spike(seed, every: 15, width: 4, amplitude: 180).round() +
          _noise(rng, 26).round(),
      0,
      b.ramTotal,
    );
    final disk = _clampDouble(
      b.disk +
          _wave(seed, period: 18, amplitude: 3.2) +
          _spike(seed, every: 21, width: 3, amplitude: 4.8) +
          _noise(rng, 1.2),
      0,
      100,
    );
    final bandwidthIn = _clampDouble(
      b.bwIn +
          _wave(seed, period: 9, amplitude: b.bwIn * 0.34 + 0.28) +
          _wave(seed, period: 4, amplitude: b.bwIn * 0.12 + 0.08, phase: 0.2) +
          _spike(seed, every: 8, width: 3, amplitude: b.bwIn * 0.9 + 0.65) +
          _noise(rng, 0.08),
      0,
      100,
    );
    final bandwidthOut = _clampDouble(
      b.bwOut +
          _wave(seed, period: 9, amplitude: b.bwOut * 0.42 + 0.16, phase: 0.4) +
          _wave(seed, period: 4, amplitude: b.bwOut * 0.18 + 0.05, phase: 0.9) +
          _spike(seed, every: 8, width: 2, amplitude: b.bwOut * 0.95 + 0.28) +
          _noise(rng, 0.05),
      0,
      100,
    );
    final latency = _clampInt(
      b.latency +
          _wave(seed, period: 7, amplitude: 6.0).round() +
          _spike(seed, every: 11, width: 2, amplitude: 14).round() +
          _noise(rng, 3.0).round(),
      0,
      1 << 30,
    );
    final loss = _clampDouble(
      b.lossBase +
          _wave(seed, period: 20, amplitude: b.lossBase * 0.5) +
          _spike(seed, every: 17, width: 2, amplitude: b.lossBase * 4) +
          _noise(rng, b.lossBase),
      0,
      10,
    );

    return Metric(
      id: 'demo-$serviceId-$seed',
      serviceId: serviceId,
      cpuUsagePercent: double.parse(cpu.toStringAsFixed(2)),
      ramUsageMb: ramUsage,
      ramTotalMb: b.ramTotal,
      diskUsagePercent: double.parse(disk.toStringAsFixed(2)),
      bandwidthInMb: double.parse(bandwidthIn.toStringAsFixed(2)),
      bandwidthOutMb: double.parse(bandwidthOut.toStringAsFixed(2)),
      uptimeSeconds: b.uptime + seed * 300,
      serviceStatus: ServiceStatus.online,
      snmpLatencyMs: latency,
      snmpLossPercent: double.parse(loss.toStringAsFixed(2)),
      collectedAt: t,
    );
  }

  static double _wave(
    int seed, {
    required double period,
    required double amplitude,
    double phase = 0,
  }) {
    final angle = ((seed + phase) / period) * math.pi * 2;
    return math.sin(angle) * amplitude;
  }

  static double _spike(
    int seed, {
    required int every,
    required int width,
    required double amplitude,
  }) {
    final position = seed % every;
    if (position >= width) return 0;

    if (width == 1) return amplitude;
    final center = (width - 1) / 2;
    final distance = (position - center).abs();
    final factor = 1 - (distance / (center + 1));
    return amplitude * factor.clamp(0, 1);
  }

  static double _noise(math.Random rng, double amplitude) {
    return (rng.nextDouble() - 0.5) * amplitude * 2;
  }

  static double _clampDouble(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }

  static int _clampInt(int value, int min, int max) {
    return value.clamp(min, max);
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
    required this.lossBase,
  });

  final double cpu;
  final int ram;
  final int ramTotal;
  final double disk;
  final double bwIn;
  final double bwOut;
  final int uptime;
  final int latency;
  final double lossBase;
}
