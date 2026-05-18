import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum UserOnlineStatus { online, offline }

class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.name,
    required this.role,
    required this.onlineStatus,
    required this.lastSeen,
    this.avatarColor,
  });

  final String name;
  final String role;
  final UserOnlineStatus onlineStatus;
  final String lastSeen;
  final Color? avatarColor;

  bool get isOnline => onlineStatus == UserOnlineStatus.online;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    final color = avatarColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.primary : AppColors.textInactive,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.panel, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.stroke.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isOnline
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : AppColors.stroke,
                  ),
                ),
                child: Text(
                  isOnline ? 'En línea' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOnline ? AppColors.primary : AppColors.textInactive,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastSeen,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textInactive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
