import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../widgets/user_list_tile.dart';
import '../user_model.dart';
import 'user_detail_sheet.dart';

class UsersList extends StatelessWidget {
  const UsersList({
    super.key,
    required this.users,
    required this.currentUserRole,
    required this.currentUserId,
  });

  final List<UserModel> users;
  final UserRole currentUserRole;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Sin usuarios registrados',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Column(
      children: List.generate(users.length, (i) {
        final m = users[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i < users.length - 1 ? 12 : 0),
          child: GestureDetector(
            onTap: () => showUserDetailSheet(
              context: context,
              model: m,
              currentUserRole: currentUserRole,
              currentUserId: currentUserId,
            ),
            child: UserListTile(
              name: m.name,
              role: m.role,
              onlineStatus: m.onlineStatus,
              lastSeen: m.lastSeen,
              avatarColor: m.avatarColor,
            ),
          ),
        );
      }),
    );
  }
}
