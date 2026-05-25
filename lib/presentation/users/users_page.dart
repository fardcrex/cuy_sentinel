import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/reconnecting_banner.dart';
import 'bloc/users_bloc.dart';
import 'bloc/users_state.dart';
import 'views/users_content_view.dart';
import 'views/users_error_view.dart';
import 'views/users_loading_view.dart';

// ── page ──────────────────────────────────────────────────────────────────────

class UsersProviderPage extends StatelessWidget {
  const UsersProviderPage({super.key});

  @override
  Widget build(BuildContext context) => const UsersPage();
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) => switch (state) {
        UsersInitial() || UsersLoading() => const UsersLoadingView(),
        UsersError(:final message) => UsersErrorView(message: message),
        UsersLoaded(:final isReconnecting, :final reconnectingInSeconds) =>
          Column(
            children: [
              if (isReconnecting)
                ReconnectingBanner(secondsLeft: reconnectingInSeconds),
              Expanded(child: UsersContentView(state: state)),
            ],
          ),
      },
    );
  }
}
