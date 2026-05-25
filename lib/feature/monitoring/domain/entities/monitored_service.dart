class MonitoredService {
  const MonitoredService({
    required this.id,
    required this.serviceName,
    required this.containerName,
    required this.hostIp,
    required this.snmpPort,
    this.slug,
    this.description,
    this.enabled = true,
    required this.createdAt,
  });

  final String id;
  final String serviceName;
  final String containerName;
  final String hostIp;
  final int snmpPort;
  final String? slug;
  final String? description;
  final bool enabled;
  final DateTime createdAt;

  factory MonitoredService.fromDynamic(dynamic data) =>
      MonitoredService.fromJson(Map<String, dynamic>.from(data as Map));

  factory MonitoredService.fromJson(Map<String, dynamic> json) =>
      MonitoredService(
        id: json['id'] as String,
        serviceName: json['service_name'] as String,
        containerName: json['container_name'] as String,
        hostIp: json['host_ip'] as String,
        snmpPort: json['snmp_port'] as int,
        slug: json['slug'] as String?,
        description: json['description'] as String?,
        enabled: (json['enabled'] as bool?) ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_name': serviceName,
    'container_name': containerName,
    'host_ip': hostIp,
    'snmp_port': snmpPort,
    'description': description,
    'enabled': enabled,
    'created_at': createdAt.toIso8601String(),
  };
}
