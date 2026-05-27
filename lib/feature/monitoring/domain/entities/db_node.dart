import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum DbNodeRole { primary, replica, standbyLeader, down }

class DbNode {
  const DbNode({
    required this.name,
    required this.host,
    required this.port,
    required this.reachable,
    required this.role,
    this.state,
    this.lag,
    this.timeline,
    this.version,
  });

  final String name;
  final String host;
  final int port;
  final bool reachable;
  final DbNodeRole role;
  final String? state;
  final int? lag;
  final int? timeline;
  final int? version;

  factory DbNode.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'down';
    final role = switch (roleStr) {
      'primary' => DbNodeRole.primary,
      'replica' => DbNodeRole.replica,
      'standby_leader' => DbNodeRole.standbyLeader,
      _ => DbNodeRole.down,
    };
    return DbNode(
      name: json['name'] as String,
      host: json['host'] as String,
      port: json['port'] as int,
      reachable: json['reachable'] as bool? ?? false,
      role: role,
      state: json['state'] as String?,
      lag: json['lag'] as int?,
      timeline: json['timeline'] as int?,
      version: json['version'] as int?,
    );
  }

  Color get statusColor => switch (role) {
    DbNodeRole.primary => AppColors.primary,
    DbNodeRole.replica || DbNodeRole.standbyLeader => AppColors.secondary,
    DbNodeRole.down => AppColors.danger,
  };

  String get roleLabel => switch (role) {
    DbNodeRole.primary => 'PRIMARY',
    DbNodeRole.replica => 'REPLICA',
    DbNodeRole.standbyLeader => 'STANDBY',
    DbNodeRole.down => 'DOWN',
  };

  String get pgVersion {
    if (version == null) return '—';
    final major = version! ~/ 10000;
    final minor = version! % 10000;
    return 'PG $major.$minor';
  }

  bool get isHealthy => reachable && role != DbNodeRole.down;
}
