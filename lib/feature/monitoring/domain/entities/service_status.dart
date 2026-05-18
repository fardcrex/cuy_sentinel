enum ServiceStatus {
  online,
  offline,
  degraded,
  warning;

  static ServiceStatus fromString(String value) => switch (value) {
    'online'   => ServiceStatus.online,
    'offline'  => ServiceStatus.offline,
    'degraded' => ServiceStatus.degraded,
    'warning'  => ServiceStatus.warning,
    _          => ServiceStatus.offline,
  };

  String toJson() => name;
}
