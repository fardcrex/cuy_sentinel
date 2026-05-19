import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/user_list_tile.dart';
import '../user_model.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key, required this.users});

  final List<UserModel> users;

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
          child: UserListTile(
            name: m.name,
            role: m.role,
            onlineStatus: m.onlineStatus,
            lastSeen: m.lastSeen,
            avatarColor: m.avatarColor,
          ),
        );
      }),
    );
  }
}
