enum UserPresenceStatus {
  active,
  away;

  static UserPresenceStatus fromString(String value) => switch (value) {
    'away' => UserPresenceStatus.away,
    _ => UserPresenceStatus.active,
  };

  String toJson() => name;
}

class UserPresence {
  const UserPresence({
    required this.userId,
    required this.deviceName,
    required this.devicePlatform,
    this.status = UserPresenceStatus.active,
  });

  final String userId;
  final String deviceName;
  final String devicePlatform;
  final UserPresenceStatus status;
}
