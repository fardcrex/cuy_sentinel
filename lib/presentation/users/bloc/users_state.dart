import '../../../feature/users/domain/entities/panel_user.dart';
import '../../../feature/users/domain/entities/user_access_log.dart';

sealed class UsersState {}

final class UsersInitial extends UsersState {}

final class UsersLoading extends UsersState {}

final class UsersLoaded extends UsersState {
  UsersLoaded({required this.users, required this.accessLogs});

  final List<PanelUser> users;
  final List<UserAccessLog> accessLogs;

  int get onlineCount => users.where((u) => u.isOnline).length;
  int get adminCount => users.where((u) => u.role == UserRole.admin).length;
  int get viewerCount => users.where((u) => u.role == UserRole.viewer).length;
}

final class UsersError extends UsersState {
  UsersError(this.message);

  final String message;
}
