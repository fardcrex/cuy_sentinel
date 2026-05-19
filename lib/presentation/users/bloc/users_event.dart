import '../../../feature/users/domain/entities/panel_user.dart';

sealed class UsersEvent {}

final class UsersWatchRequested extends UsersEvent {}

final class UserRoleChanged extends UsersEvent {
  UserRoleChanged({required this.userId, required this.newRole});

  final String userId;
  final UserRole newRole;
}

final class UserDeactivated extends UsersEvent {
  UserDeactivated({required this.userId});

  final String userId;
}
