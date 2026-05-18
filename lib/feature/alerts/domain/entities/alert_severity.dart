enum AlertSeverity {
  critical,
  warning,
  info;

  static AlertSeverity fromString(String value) => switch (value) {
    'critical' => AlertSeverity.critical,
    'warning'  => AlertSeverity.warning,
    'info'     => AlertSeverity.info,
    _          => AlertSeverity.info,
  };

  String toJson() => name;
}
