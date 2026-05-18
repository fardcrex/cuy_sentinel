class MonitoredService {
  const MonitoredService({
    required this.id,
    required this.serviceName,
    this.containerName,
    this.hostIp,
    this.snmpPort = 161,
    required this.createdAt,
  });

  final int id;
  final String serviceName;
  final String? containerName;
  final String? hostIp;
  final int snmpPort;
  final DateTime createdAt;

  factory MonitoredService.fromJson(Map<String, dynamic> json) {
    return MonitoredService(
      id: json['id'] as int,
      serviceName: json['service_name'] as String,
      containerName: json['container_name'] as String?,
      hostIp: json['host_ip'] as String?,
      snmpPort: (json['snmp_port'] as int?) ?? 161,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_name': serviceName,
    'container_name': containerName,
    'host_ip': hostIp,
    'snmp_port': snmpPort,
    'created_at': createdAt.toIso8601String(),
  };
}
