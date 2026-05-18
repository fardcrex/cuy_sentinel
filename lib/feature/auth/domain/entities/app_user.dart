class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  final int id;
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'viewer'),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }
}

enum UserRole {
  admin,
  viewer;

  static UserRole fromString(String value) =>
      value == 'admin' ? UserRole.admin : UserRole.viewer;
}
