import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../auth/bloc/auth_bloc.dart';
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

    final userModels = List.generate(
      state.users.length,
      (i) => state.users[i].toModel(
        i,
        isOnline: state.isOnline(state.users[i].id),
        allLogs: state.accessLogs,
        presences: state.presences,
      ),
    );
    final logModels = state.accessLogs.map((l) => l.toModel()).toList();
    final session = state.toSessionModel();

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
