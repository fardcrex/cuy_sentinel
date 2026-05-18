class CollectorRun {
  const CollectorRun({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    this.durationMs,
    required this.servicesPolled,
    required this.success,
    this.errorMessage,
    this.collectorVersion,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? finishedAt;

  /// Populated by the DB generated column; null while still running.
  final int? durationMs;

  final int servicesPolled;
  final bool success;
  final String? errorMessage;
  final String? collectorVersion;

  bool get isRunning => finishedAt == null;

  factory CollectorRun.fromJson(Map<String, dynamic> json) => CollectorRun(
    id: json['id'] as String,
    startedAt: DateTime.parse(json['started_at'] as String),
    finishedAt: json['finished_at'] != null
        ? DateTime.parse(json['finished_at'] as String)
        : null,
    durationMs: json['duration_ms'] as int?,
    servicesPolled: (json['services_polled'] as int?) ?? 0,
    success: (json['success'] as bool?) ?? false,
    errorMessage: json['error_message'] as String?,
    collectorVersion: json['collector_version'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'started_at': startedAt.toIso8601String(),
    'finished_at': finishedAt?.toIso8601String(),
    'services_polled': servicesPolled,
    'success': success,
    'error_message': errorMessage,
    'collector_version': collectorVersion,
  };
}
