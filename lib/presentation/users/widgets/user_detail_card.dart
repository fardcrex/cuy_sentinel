import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../widgets/user_list_tile.dart';
import '../user_model.dart';

class UserDetailCard extends StatelessWidget {
  const UserDetailCard({
    super.key,
    required this.model,
    required this.currentUserRole,
    required this.currentUserId,
    required this.isBottomSheet,
    this.onPromoteToAdmin,
    this.onDemoteToViewer,
  });

  final UserModel model;
  final UserRole currentUserRole;
  final String currentUserId;
  final bool isBottomSheet;
  final VoidCallback? onPromoteToAdmin;
  final VoidCallback? onDemoteToViewer;

  bool get _isOwnProfile => model.userId == currentUserId;

  bool get _showPromote =>
      !_isOwnProfile &&
      (currentUserRole == UserRole.admin || currentUserRole == UserRole.master) &&
      model.rawRole == UserRole.viewer;

  bool get _showDemote =>
      !_isOwnProfile &&
      currentUserRole == UserRole.master &&
      model.rawRole == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    final radius = isBottomSheet
        ? const BorderRadius.vertical(top: Radius.circular(24))
        : BorderRadius.circular(16);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: radius,
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBottomSheet) const _DragHandle(),
          _UserDetailHeader(model: model),
          const Divider(color: AppColors.stroke, height: 1),
          _UserDetailInfoSection(model: model),
          const Divider(color: AppColors.stroke, height: 1),
          _UserDetailDevicesSection(devices: model.devices),
          if (_showPromote || _showDemote) ...[
            const Divider(color: AppColors.stroke, height: 1),
            _UserDetailActions(
              showPromote: _showPromote,
              showDemote: _showDemote,
              onPromoteToAdmin: onPromoteToAdmin,
              onDemoteToViewer: onDemoteToViewer,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _UserDetailHeader extends StatelessWidget {
  const _UserDetailHeader({required this.model});

  final UserModel model;

  @override
  Widget build(BuildContext context) {
    final initials = model.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: model.avatarColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: model.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: model.onlineStatus == UserOnlineStatus.online
                        ? AppColors.primary
                        : AppColors.textInactive,
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
                Text(
                  model.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      model.role,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _OnlineBadge(
                      isOnline: model.onlineStatus == UserOnlineStatus.online,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info rows ─────────────────────────────────────────────────────────────────

class _UserDetailInfoSection extends StatelessWidget {
  const _UserDetailInfoSection({required this.model});

  final UserModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined, text: model.email),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.shield_outlined, text: model.role),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: 'Registrado: ${model.createdAt}',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: 'Último acceso: ${model.lastSeen}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

// ── Devices ───────────────────────────────────────────────────────────────────

class _UserDetailDevicesSection extends StatelessWidget {
  const _UserDetailDevicesSection({required this.devices});

  final List<UserDeviceModel> devices;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISPOSITIVOS ACTIVOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textInactive,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 10),
          if (devices.isEmpty)
            Text(
              'Sin dispositivos activos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInactive,
                  ),
            )
          else
            ...devices.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        d.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    Text(
                      d.ip,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textInactive,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Actions ───────────────────────────────────────────────────────────────────

class _UserDetailActions extends StatelessWidget {
  const _UserDetailActions({
    required this.showPromote,
    required this.showDemote,
    this.onPromoteToAdmin,
    this.onDemoteToViewer,
  });

  final bool showPromote;
  final bool showDemote;
  final VoidCallback? onPromoteToAdmin;
  final VoidCallback? onDemoteToViewer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          if (showPromote)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  onPromoteToAdmin?.call();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                label: const Text('Hacer Admin'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.voidBlack,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          if (showPromote && showDemote) const SizedBox(height: 8),
          if (showDemote)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  onDemoteToViewer?.call();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                label: const Text('Quitar Admin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.stroke,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOnline ? AppColors.primary : AppColors.textInactive,
        ),
      ),
    );
  }
}
