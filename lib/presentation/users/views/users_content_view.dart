import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
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
    final userModels = List.generate(
      state.users.length,
      (i) => state.users[i].toModel(
        i,
        isOnline: state.isOnline(state.users[i].id),
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
                      child: UsersList(users: userModels),
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
                    UsersList(users: userModels),
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
