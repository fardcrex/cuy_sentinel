import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/utils/app_toast.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_state.dart';
import '../user_model.dart';
import 'user_detail_card.dart';

void showUserDetailSheet({
  required BuildContext context,
  required UserModel model,
  required UserRole currentUserRole,
  required String currentUserId,
}) {
  // Capturar el BLoC antes de abrir el overlay para que los callbacks
  // puedan acceder a él aunque el context original ya no esté en el árbol.
  final bloc = context.read<UsersBloc>();

  if (model.rawRole == UserRole.master && currentUserRole != UserRole.master) {
    return;
  }

  Future<void> promoteToAdmin() async {
    try {
      await bloc.changeRole(model.userId, UserRole.admin);
      if (context.mounted) {
        AppToast.success(context, 'Usuario promovido a admin.');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          'No se pudo promover el usuario.',
          detail: _cleanError(e),
        );
      }
      rethrow;
    }
  }

  Future<void> demoteToViewer() async {
    try {
      await bloc.changeRole(model.userId, UserRole.viewer);
      if (context.mounted) {
        AppToast.success(context, 'Usuario despromovido a visualizador.');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          'No se pudo despromover el usuario.',
          detail: _cleanError(e),
        );
      }
      rethrow;
    }
  }

  final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);

  if (isMobile) {
    final bottomOffset = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomOffset),
          child: _ReactiveUserDetailCard(
            initialModel: model,
            targetUserId: model.userId,
            currentUserRole: currentUserRole,
            currentUserId: currentUserId,
            isBottomSheet: true,
            onPromoteToAdmin: promoteToAdmin,
            onDemoteToViewer: demoteToViewer,
          ),
        ),
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _ReactiveUserDetailCard(
              initialModel: model,
              targetUserId: model.userId,
              currentUserRole: currentUserRole,
              currentUserId: currentUserId,
              isBottomSheet: false,
              onPromoteToAdmin: promoteToAdmin,
              onDemoteToViewer: demoteToViewer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactiveUserDetailCard extends StatelessWidget {
  const _ReactiveUserDetailCard({
    required this.initialModel,
    required this.targetUserId,
    required this.currentUserRole,
    required this.currentUserId,
    required this.isBottomSheet,
    this.onPromoteToAdmin,
    this.onDemoteToViewer,
  });

  final UserModel initialModel;
  final String targetUserId;
  final UserRole currentUserRole;
  final String currentUserId;
  final bool isBottomSheet;
  final Future<void> Function()? onPromoteToAdmin;
  final Future<void> Function()? onDemoteToViewer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        final (:model, :role) = switch (state) {
          UsersLoaded() => _resolveLiveModel(state),
          _ => (model: initialModel, role: currentUserRole),
        };

        return UserDetailCard(
          model: model,
          currentUserRole: role,
          currentUserId: currentUserId,
          isBottomSheet: isBottomSheet,
          onPromoteToAdmin: onPromoteToAdmin,
          onDemoteToViewer: onDemoteToViewer,
        );
      },
    );
  }

  ({UserModel model, UserRole role}) _resolveLiveModel(UsersLoaded state) {
    final targetIndex = state.users.indexWhere((u) => u.id == targetUserId);
    final targetUser = targetIndex == -1 ? null : state.users[targetIndex];
    final currentUser = state.users
        .where((u) => u.id == currentUserId)
        .firstOrNull;

    return (
      model: targetUser == null
          ? initialModel
          : targetUser.toModel(
              targetIndex,
              allLogs: state.accessLogs,
              presences: state.presences,
            ),
      role: currentUser?.role ?? currentUserRole,
    );
  }
}

String _cleanError(Object error) {
  final message = error.toString();
  return message.startsWith('Exception: ')
      ? message.replaceFirst('Exception: ', '')
      : message;
}
