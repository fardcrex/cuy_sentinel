enum MetricsRange { h1, h6, h24, d7 }

extension MetricsRangeX on MetricsRange {
  Duration get duration => [
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(hours: 24),
    const Duration(days: 7),
  ][index];

  Duration get bucketSize =>
      Duration(milliseconds: duration.inMilliseconds ~/ 12);

  Duration get lookbackTolerance => Duration(
        milliseconds: (bucketSize.inMilliseconds * 1.5).round(),
      );

  String get label => ['1h', '6h', '24h', '7d'][index];
}
