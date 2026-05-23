enum UserRole {
  master,
  admin,
  viewer;

  static UserRole fromString(String value) => switch (value) {
    'master' => UserRole.master,
    'admin'  => UserRole.admin,
    'viewer' => UserRole.viewer,
    _        => UserRole.viewer,
  };

  String toJson() => name;
}

class PanelUser {
  const PanelUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.lastLogin,
    this.sessionExpiresAt,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime? lastLogin;

  /// JWT expiry (Fase 2). In Fase 1 with Supabase Auth, use Supabase session.
  final DateTime? sessionExpiresAt;
  final DateTime createdAt;

  /// A user is considered online if their session has not yet expired.
  bool get isOnline {
    if (sessionExpiresAt == null) return false;
    return sessionExpiresAt!.isAfter(DateTime.now());
  }

  factory PanelUser.fromJson(Map<String, dynamic> json) => PanelUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String,
    role: UserRole.fromString(json['role'] as String),
    lastLogin: json['last_login'] != null
        ? DateTime.parse(json['last_login'] as String)
        : null,
    sessionExpiresAt: json['session_expires_at'] != null
        ? DateTime.parse(json['session_expires_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'role': role.toJson(),
    'last_login': lastLogin?.toIso8601String(),
    'session_expires_at': sessionExpiresAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
