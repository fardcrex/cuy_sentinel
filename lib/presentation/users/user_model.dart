import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/users/domain/entities/panel_user.dart';
import '../../feature/users/domain/entities/user_access_log.dart';
import '../widgets/user_list_tile.dart';
import 'bloc/users_state.dart';

// ── private helpers ───────────────────────────────────────────────────────────

const _avatarColors = [
  AppColors.primary,
  AppColors.secondary,
  AppColors.primaryBright,
];

String _roleLabel(UserRole role) => switch (role) {
      UserRole.master => 'Master',
      UserRole.admin  => 'Administrador',
      UserRole.viewer => 'Visualizador',
    };

String _formatRelative(DateTime? dt) {
  if (dt == null) return 'Nunca';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays == 1) return 'Ayer';
  return 'Hace ${diff.inDays} días';
}

String _formatDate(DateTime dt) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

String _formatLogTimestamp(DateTime dt) {
  final now = DateTime.now();
  final isToday =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  final isYesterday = DateTime(dt.year, dt.month, dt.day)
      .isAtSameMomentAs(DateTime(now.year, now.month, now.day - 1));
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  if (isToday) return 'Hoy $h:$m';
  if (isYesterday) return 'Ayer $h:$m';
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${dt.day} ${months[dt.month - 1]} $h:$m';
}

// ── models ────────────────────────────────────────────────────────────────────

class UserDeviceModel {
  UserDeviceModel({required this.label, this.platform});

  final String label;
  final String? platform;
}

/// UI representation of a [PanelUser] — feeds [UserListTile] and [UserDetailCard].
class UserModel {
  UserModel({
    required this.userId,
    required this.name,
    required this.role,
    required this.rawRole,
    required this.email,
    required this.createdAt,
    required this.onlineStatus,
    required this.lastSeen,
    required this.avatarColor,
    required this.devices,
  });

  final String userId;
  final String name;
  final String role;
  final UserRole rawRole;
  final String email;
  final String createdAt;
  final UserOnlineStatus onlineStatus;
  final String lastSeen;
  final Color avatarColor;
  final List<UserDeviceModel> devices;
}

/// UI representation of a [UserAccessLog] — feeds the access log rows.
class AccessLogModel {
  AccessLogModel({
    required this.user,
    required this.action,
    required this.timestamp,
    required this.color,
    this.deviceLabel,
    this.devicePlatform,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;
  final String? deviceLabel;
  final String? devicePlatform;
}

/// UI-ready stats for the session summary card and the online badge.
class UsersSessionModel {
  UsersSessionModel({
    required this.onlineLabel,
    required this.total,
    required this.online,
    required this.admins,
    required this.viewers,
  });

  final String onlineLabel;
  final String total;
  final String online;
  final String admins;
  final String viewers;
}

// ── extensions ────────────────────────────────────────────────────────────────

extension UserModelX on PanelUser {
  UserModel toModel(
    int index, {
    required bool isOnline,
    List<UserAccessLog> allLogs = const [],
  }) {
    final devices = allLogs
        .where((l) => l.userId == id && l.deviceName != null)
        .fold<Map<String, UserAccessLog>>({}, (map, log) {
          final key = log.deviceName!;
          if (!map.containsKey(key) ||
              log.timestamp.isAfter(map[key]!.timestamp)) {
            map[key] = log;
          }
          return map;
        })
        .values
        .map((l) => UserDeviceModel(label: l.deviceName!, platform: l.devicePlatform))
        .toList();

    return UserModel(
      userId: id,
      name: displayName,
      role: _roleLabel(role),
      rawRole: role,
      email: email,
      createdAt: _formatDate(createdAt),
      onlineStatus: isOnline ? UserOnlineStatus.online : UserOnlineStatus.offline,
      lastSeen: _formatRelative(lastLogin),
      avatarColor: _avatarColors[index % _avatarColors.length],
      devices: devices,
    );
  }
}

extension AccessLogModelX on UserAccessLog {
  AccessLogModel toModel() => AccessLogModel(
        user: displayName,
        action: action == UserAccessAction.login
            ? 'Inicio de sesión'
            : 'Cierre de sesión',
        timestamp: _formatLogTimestamp(timestamp),
        color: action == UserAccessAction.login
            ? AppColors.primary
            : AppColors.textSecondary,
        deviceLabel: deviceName,
        devicePlatform: devicePlatform,
      );
}

extension UsersSessionModelX on UsersLoaded {
  UsersSessionModel toSessionModel() => UsersSessionModel(
        onlineLabel: '$onlineCount en línea',
        total: '${users.length}',
        online: '$onlineCount',
        admins: '$adminCount',
        viewers: '$viewerCount',
      );
}
