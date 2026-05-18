import 'package:flutter/material.dart';

import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import 'widgets/screen_header.dart';
import 'widgets/user_list_tile.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Usuarios',
                subtitle: 'Sesiones activas y actividad reciente de acceso al panel',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: AppColors.primary,
                        size: 8,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '1 en línea',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 3, child: _UserList()),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: const [
                          _SessionStatsCard(),
                          SizedBox(height: 20),
                          _AccessLogCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    _SessionStatsCard(),
                    SizedBox(height: 20),
                    _UserList(),
                    SizedBox(height: 20),
                    _AccessLogCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        UserListTile(
          name: 'Jair Conislla',
          role: 'Administrador',
          onlineStatus: UserOnlineStatus.online,
          lastSeen: 'Hace 2 min',
          avatarColor: AppColors.primary,
        ),
        SizedBox(height: 12),
        UserListTile(
          name: 'Daniel Rojas',
          role: 'Visualizador',
          onlineStatus: UserOnlineStatus.offline,
          lastSeen: 'Hace 3h',
          avatarColor: AppColors.secondary,
        ),
        SizedBox(height: 12),
        UserListTile(
          name: 'Jheampierre Ralli',
          role: 'Visualizador',
          onlineStatus: UserOnlineStatus.offline,
          lastSeen: 'Hace 1d',
          avatarColor: AppColors.primaryBright,
        ),
      ],
    );
  }
}

class _SessionStatsCard extends StatelessWidget {
  const _SessionStatsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de sesiones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          const _StatRow(
            icon: Icons.people_rounded,
            label: 'Total de usuarios',
            value: '3',
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          const _StatRow(
            icon: Icons.circle,
            label: 'En línea ahora',
            value: '1',
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          const _StatRow(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Administradores',
            value: '1',
            color: AppColors.primaryBright,
          ),
          const SizedBox(height: 14),
          const _StatRow(
            icon: Icons.visibility_outlined,
            label: 'Visualizadores',
            value: '2',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Autenticación con contraseña. JWT en Fase 2.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _AccessLogCard extends StatelessWidget {
  const _AccessLogCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos recientes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _LogEntry(
            user: 'Jair Conislla',
            action: 'Inicio de sesión',
            timestamp: 'Hoy 18:43',
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          const _LogEntry(
            user: 'Daniel Rojas',
            action: 'Inicio de sesión',
            timestamp: 'Hoy 15:22',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          const _LogEntry(
            user: 'Daniel Rojas',
            action: 'Cierre de sesión',
            timestamp: 'Hoy 15:58',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          const _LogEntry(
            user: 'Jheampierre Ralli',
            action: 'Inicio de sesión',
            timestamp: 'Ayer 09:11',
            color: AppColors.primaryBright,
          ),
          const SizedBox(height: 10),
          const _LogEntry(
            user: 'Jheampierre Ralli',
            action: 'Cierre de sesión',
            timestamp: 'Ayer 10:34',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  const _LogEntry({
    required this.user,
    required this.action,
    required this.timestamp,
    required this.color,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: user,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' · $action',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          timestamp,
          style: const TextStyle(
            color: AppColors.textInactive,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
