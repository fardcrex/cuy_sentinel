enum ServiceEventType {
  down,
  recovered,
  degraded,
  warning;

  static ServiceEventType fromString(String value) => switch (value) {
    'down'      => ServiceEventType.down,
    'recovered' => ServiceEventType.recovered,
    'degraded'  => ServiceEventType.degraded,
    'warning'   => ServiceEventType.warning,
    _           => ServiceEventType.down,
  };

  String toJson() => name;
}

class ServiceEvent {
  const ServiceEvent({
    required this.id,
    required this.serviceId,
    required this.eventType,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.cause,
    this.resolved = false,
    required this.createdAt,
  });

  final String id;
  final String serviceId;
  final ServiceEventType eventType;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Populated by the DB generated column; null while event is still active.
  final int? durationSeconds;

  final String? cause;
  final bool resolved;
  final DateTime createdAt;

  bool get isActive => endedAt == null && !resolved;

  factory ServiceEvent.fromJson(Map<String, dynamic> json) => ServiceEvent(
    id: json['id'] as String,
    serviceId: json['service_id'] as String,
    eventType: ServiceEventType.fromString(json['event_type'] as String),
    startedAt: DateTime.parse(json['started_at'] as String),
    endedAt: json['ended_at'] != null
        ? DateTime.parse(json['ended_at'] as String)
        : null,
    durationSeconds: json['duration_s'] as int?,
    cause: json['cause'] as String?,
    resolved: (json['resolved'] as bool?) ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_id': serviceId,
    'event_type': eventType.toJson(),
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'cause': cause,
    'resolved': resolved,
    'created_at': createdAt.toIso8601String(),
  };
}
