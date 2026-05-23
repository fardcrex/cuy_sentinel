import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cuy_sentinel/core/theme/app_colors.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/panel_user.dart';
import 'package:cuy_sentinel/presentation/users/user_model.dart';
import 'package:cuy_sentinel/presentation/users/widgets/user_detail_card.dart';
import 'package:cuy_sentinel/presentation/widgets/user_list_tile.dart';

Widget _buildCard({
  required UserRole currentUserRole,
  required UserRole targetRole,
  String currentUserId = 'usr-current',
  String targetUserId = 'usr-target',
  bool isBottomSheet = false,
}) {
  final model = UserModel(
    userId: targetUserId,
    name: 'Ana García',
    role: targetRole == UserRole.admin ? 'Administrador' : 'Visualizador',
    rawRole: targetRole,
    email: 'ana@test.com',
    createdAt: '1 ene 2025',
    onlineStatus: UserOnlineStatus.online,
    lastSeen: 'Ahora',
    avatarColor: AppColors.primary,
    devices: [
      UserDeviceModel(label: 'Chrome · macOS', isOnline: true, platform: 'web'),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: UserDetailCard(
          model: model,
          currentUserRole: currentUserRole,
          currentUserId: currentUserId,
          isBottomSheet: isBottomSheet,
        ),
      ),
    ),
  );
}

void main() {
  group('UserDetailCard', () {
    testWidgets('muestra el nombre del usuario', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          currentUserRole: UserRole.viewer,
          targetRole: UserRole.viewer,
        ),
      );
      expect(find.text('Ana García'), findsOneWidget);
    });

    testWidgets('muestra el email del usuario', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          currentUserRole: UserRole.viewer,
          targetRole: UserRole.viewer,
        ),
      );
      expect(find.text('ana@test.com'), findsOneWidget);
    });

    testWidgets('admin ve botón Hacer Admin sobre viewer', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          currentUserRole: UserRole.admin,
          targetRole: UserRole.viewer,
        ),
      );
      expect(find.text('Hacer Admin'), findsOneWidget);
    });

    testWidgets('viewer NO ve botón Hacer Admin sobre viewer', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          currentUserRole: UserRole.viewer,
          targetRole: UserRole.viewer,
        ),
      );
      expect(find.text('Hacer Admin'), findsNothing);
    });

    testWidgets('master ve botón Quitar Admin sobre admin', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          currentUserRole: UserRole.master,
          targetRole: UserRole.admin,
        ),
      );
      expect(find.text('Quitar Admin'), findsOneWidget);
    });

    testWidgets('admin NO ve botón Quitar Admin sobre admin', (tester) async {
      await tester.pumpWidget(
        _buildCard(currentUserRole: UserRole.admin, targetRole: UserRole.admin),
      );
      expect(find.text('Quitar Admin'), findsNothing);
    });

    testWidgets('no muestra acciones sobre perfil propio', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          currentUserRole: UserRole.master,
          targetRole: UserRole.viewer,
          currentUserId: 'mismo-usuario',
          targetUserId: 'mismo-usuario',
        ),
      );
      expect(find.text('Hacer Admin'), findsNothing);
      expect(find.text('Quitar Admin'), findsNothing);
    });

    testWidgets(
      'master ve Hacer Admin Y Quitar Admin según el rol del target',
      (tester) async {
        await tester.pumpWidget(
          _buildCard(
            currentUserRole: UserRole.master,
            targetRole: UserRole.viewer,
          ),
        );
        expect(find.text('Hacer Admin'), findsOneWidget);
        expect(find.text('Quitar Admin'), findsNothing);
      },
    );
  });
}
