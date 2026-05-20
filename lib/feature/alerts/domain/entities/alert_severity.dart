enum AlertSeverity {
  critical,
  nuclear,
  warning,
  info;

  static AlertSeverity fromString(String value) => switch (value) {
    'critical' => AlertSeverity.critical,
    'nuclear' => AlertSeverity.nuclear,
    'warning' => AlertSeverity.warning,
    'info' => AlertSeverity.info,
    _ => AlertSeverity.info,
  };

  String toJson() => name;
}
