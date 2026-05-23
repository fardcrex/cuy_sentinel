import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../bloc/users_bloc.dart';
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

  void promoteToAdmin() => bloc.changeRole(model.userId, UserRole.admin);
  void demoteToViewer() => bloc.changeRole(model.userId, UserRole.viewer);

  final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);

  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => UserDetailCard(
        model: model,
        currentUserRole: currentUserRole,
        currentUserId: currentUserId,
        isBottomSheet: true,
        onPromoteToAdmin: promoteToAdmin,
        onDemoteToViewer: demoteToViewer,
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: UserDetailCard(
            model: model,
            currentUserRole: currentUserRole,
            currentUserId: currentUserId,
            isBottomSheet: false,
            onPromoteToAdmin: promoteToAdmin,
            onDemoteToViewer: demoteToViewer,
          ),
        ),
      ),
    );
  }
}
