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

/// A single login/logout event. Stored in an access_logs table in Fase 2;
/// in Fase 1 it can be derived from Supabase Auth audit logs.
class UserAccessLog {
  const UserAccessLog({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.action,
    required this.timestamp,
    this.ipAddress,
  });

  final String id;
  final String userId;
  final String displayName;
  final UserAccessAction action;
  final DateTime timestamp;

  /// Optional: captured from request headers by the API (Fase 2).
  final String? ipAddress;

  factory UserAccessLog.fromJson(Map<String, dynamic> json) => UserAccessLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    displayName: json['display_name'] as String,
    action: UserAccessAction.fromString(json['action'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
    ipAddress: json['ip_address'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'display_name': displayName,
    'action': action.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'ip_address': ipAddress,
  };
}
