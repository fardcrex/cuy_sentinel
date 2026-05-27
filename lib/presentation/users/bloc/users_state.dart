import '../../../feature/users/domain/entities/panel_user.dart';
import '../../../feature/users/domain/entities/user_access_log.dart';
import '../../../feature/users/domain/entities/user_presence.dart';

sealed class UsersState {}

final class UsersInitial extends UsersState {}

final class UsersLoading extends UsersState {}

final class UsersLoaded extends UsersState {
  UsersLoaded({
    required this.users,
    required this.accessLogs,
    required this.presences,
    this.isReconnecting = false,
    this.reconnectingInSeconds,
  });

  final List<PanelUser> users;
  final List<UserAccessLog> accessLogs;
  final List<UserPresence> presences;
  final bool isReconnecting;
  final int? reconnectingInSeconds;

  Set<String> get onlineIds {
    if (presences.isNotEmpty) return presences.map((p) => p.userId).toSet();
    // Phase 2: no real-time presence — fall back to session_expires_at on each user.
    return users.where((u) => u.isOnline).map((u) => u.id).toSet();
  }

  bool isOnline(String userId) => onlineIds.contains(userId);
  int get onlineCount => onlineIds.length;
  int get adminCount => users
      .where((u) => u.role == UserRole.admin || u.role == UserRole.master)
      .length;
  int get viewerCount => users.where((u) => u.role == UserRole.viewer).length;
}

final class UsersError extends UsersState {
  UsersError(this.message);

  final String message;
}
