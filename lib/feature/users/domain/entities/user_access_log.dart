enum UserAccessAction {
  login,
  logout;

  static UserAccessAction fromString(String value) => switch (value) {
    'login'  => UserAccessAction.login,
    'logout' => UserAccessAction.logout,
    _        => UserAccessAction.login,
  };

  String toJson() => name;
}

class UserAccessLog {
  const UserAccessLog({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.action,
    required this.timestamp,
    this.ipAddress,
    this.deviceName,
    this.devicePlatform,
  });

  final String id;
  final String userId;
  final String displayName;
  final UserAccessAction action;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceName;
  final String? devicePlatform;

  factory UserAccessLog.fromJson(Map<String, dynamic> json) => UserAccessLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    displayName: json['display_name'] as String,
    action: UserAccessAction.fromString(json['action'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    ipAddress: json['ip_address'] as String?,
    deviceName: json['device_name'] as String?,
    devicePlatform: json['device_platform'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'display_name': displayName,
    'action': action.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'ip_address': ipAddress,
    'device_name': deviceName,
    'device_platform': devicePlatform,
  };
}
