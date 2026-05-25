import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../widgets/nav_style_cubit.dart';
import '../../widgets/screen_header.dart';
import '../bloc/users_state.dart';
import '../user_model.dart';
import '../widgets/users_access_log_card.dart';
import '../widgets/users_list.dart';
import '../widgets/users_online_badge.dart';
import '../widgets/users_session_stats_card.dart';

class UsersContentView extends StatelessWidget {
  const UsersContentView({super.key, required this.state});

  final UsersLoaded state;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : '';
    final currentUserEmail = authState is AuthAuthenticated
        ? authState.user.email
        : '';
    final currentUserRole =
        state.users.where((u) => u.id == currentUserId).firstOrNull?.role ??
        UserRole.viewer;
    final visibleUsers = currentUserRole == UserRole.master
        ? state.users
        : state.users.where((u) => u.role != UserRole.master).toList();
    final visibleUserIds = visibleUsers.map((u) => u.id).toSet();
    final visibleState = UsersLoaded(
      users: visibleUsers,
      accessLogs: state.accessLogs
          .where((log) => visibleUserIds.contains(log.userId))
          .toList(),
      presences: state.presences
          .where((presence) => visibleUserIds.contains(presence.userId))
          .toList(),
      isReconnecting: state.isReconnecting,
      reconnectingInSeconds: state.reconnectingInSeconds,
    );

    final userModels = List.generate(
      visibleState.users.length,
      (i) => visibleState.users[i].toModel(
        i,
        allLogs: visibleState.accessLogs,
        presences: visibleState.presences,
      ),
    );
    final logModels = visibleState.accessLogs.map((l) => l.toModel()).toList();
    final session = visibleState.toSessionModel();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            padding,
            padding,
            padding,
            padding + bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Usuarios',
                titleTrailing: currentUserEmail.isEmpty
                    ? null
                    : _CurrentUserEmailPill(email: currentUserEmail),
                subtitle:
                    'Sesiones activas y actividad reciente de acceso al panel',
                trailing: UsersOnlineBadge(label: session.onlineLabel),
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: UsersList(
                        users: userModels,
                        currentUserRole: currentUserRole,
                        currentUserId: currentUserId,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          UsersSessionStatsCard(session: session),
                          const SizedBox(height: 20),
                          UsersAccessLogCard(logs: logModels),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    UsersSessionStatsCard(session: session),
                    const SizedBox(height: 20),
                    UsersList(
                      users: userModels,
                      currentUserRole: currentUserRole,
                      currentUserId: currentUserId,
                    ),
                    const SizedBox(height: 20),
                    UsersAccessLogCard(logs: logModels),
                  ],
                ),
              const SizedBox(height: 32),
              const _NavStyleToggle(),
            ],
          ),
        );
      },
    );
  }
}

class _NavStyleToggle extends StatelessWidget {
  const _NavStyleToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavStyleCubit, NavGlassStyle>(
      builder: (context, style) {
        final isTeal = style == NavGlassStyle.teal;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.blur_on_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estilo de navegación',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTeal ? 'Teal glass' : 'Dark glass',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isTeal,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => context.read<NavStyleCubit>().toggle(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrentUserEmailPill extends StatelessWidget {
  const _CurrentUserEmailPill({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        email,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
