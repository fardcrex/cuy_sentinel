# User Detail Dialog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Al tocar un `UserListTile`, abrir un dialog (tablet+) o bottom sheet (mobile) con el detalle del usuario, incluyendo botones condicionales de cambio de rol según la jerarquía master > admin > viewer.

**Architecture:** La función `showUserDetailSheet` bifurca entre `showModalBottomSheet` y `showDialog` según el ancho de pantalla. El widget de contenido `UserDetailCard` es compartido. El rol del usuario en sesión se obtiene en `UsersContentView` buscando `AppUser.id` dentro de `UsersLoaded.users` — sin tocar la capa de auth. Los cambios de rol son optimistas (actualización inmediata de la lista en memoria; backend pendiente).

**Tech Stack:** Flutter, BLoC/Cubit, `flutter_bloc`, `flutter_test` (widget tests), `AppBreakpoints` para breakpoints.

---

## Nota de diseño: desviación del spec

El spec proponía añadir `role` a `AppUser`. Este plan lo descarta: el rol ya está en `UsersLoaded.users` y buscarlo por `AppUser.id` es más simple y no duplica estado.

---

## Mapa de archivos

| Acción | Archivo |
|--------|---------|
| Modificar | `lib/feature/users/domain/entities/panel_user.dart` |
| Modificar | `lib/feature/users/infrastructure/in_memory_users_repository.dart` |
| Modificar | `lib/feature/auth/infrastructure/in_memory_auth_repository.dart` |
| Modificar | `lib/presentation/users/bloc/users_state.dart` |
| Modificar | `lib/presentation/users/bloc/users_bloc.dart` |
| Modificar | `lib/presentation/users/user_model.dart` |
| Modificar | `lib/presentation/users/views/users_content_view.dart` |
| Modificar | `lib/presentation/users/widgets/users_list.dart` |
| Crear | `lib/presentation/users/widgets/user_detail_card.dart` |
| Crear | `lib/presentation/users/widgets/user_detail_sheet.dart` |
| Crear | `test/presentation/users/widgets/user_detail_card_test.dart` |

---

## Task 1: UserRole.master — dominio y datos de demo

**Files:**
- Modify: `lib/feature/users/domain/entities/panel_user.dart`
- Modify: `lib/feature/users/infrastructure/in_memory_users_repository.dart`
- Modify: `lib/feature/auth/infrastructure/in_memory_auth_repository.dart`
- Modify: `lib/presentation/users/bloc/users_state.dart`

- [ ] **Step 1: Añadir `master` al enum `UserRole`**

Reemplazar el contenido de `lib/feature/users/domain/entities/panel_user.dart`:

```dart
enum UserRole {
  master,
  admin,
  viewer;

  static UserRole fromString(String value) => switch (value) {
    'master' => UserRole.master,
    'admin'  => UserRole.admin,
    'viewer' => UserRole.viewer,
    _        => UserRole.viewer,
  };

  String toJson() => name;
}

class PanelUser {
  const PanelUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.lastLogin,
    this.sessionExpiresAt,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime? lastLogin;
  final DateTime? sessionExpiresAt;
  final DateTime createdAt;

  bool get isOnline {
    if (sessionExpiresAt == null) return false;
    return sessionExpiresAt!.isAfter(DateTime.now());
  }

  factory PanelUser.fromJson(Map<String, dynamic> json) => PanelUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String,
    role: UserRole.fromString(json['role'] as String),
    lastLogin: json['last_login'] != null
        ? DateTime.parse(json['last_login'] as String)
        : null,
    sessionExpiresAt: json['session_expires_at'] != null
        ? DateTime.parse(json['session_expires_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'role': role.toJson(),
    'last_login': lastLogin?.toIso8601String(),
    'session_expires_at': sessionExpiresAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
```

- [ ] **Step 2: Actualizar `adminCount` en `UsersLoaded` para incluir master**

En `lib/presentation/users/bloc/users_state.dart`, cambiar:

```dart
int get adminCount => users.where((u) => u.role == UserRole.admin).length;
```

por:

```dart
int get adminCount =>
    users.where((u) => u.role == UserRole.admin || u.role == UserRole.master).length;
```

- [ ] **Step 3: Hacer `usr-jair` master en los datos de demo**

En `lib/feature/users/infrastructure/in_memory_users_repository.dart`, cambiar `role: UserRole.admin` de `usr-jair` por `role: UserRole.master`:

```dart
PanelUser(
  id: 'usr-jair',
  email: 'jair@cuy-sentinel.local',
  displayName: 'Jair Conislla',
  role: UserRole.master,           // ← era admin
  lastLogin: _now.subtract(const Duration(minutes: 12)),
  sessionExpiresAt: _now.add(const Duration(hours: 8)),
  createdAt: DateTime(2025, 3, 1),
),
```

- [ ] **Step 4: Cambiar el id del usuario demo en `InMemoryAuthRepository`**

En `lib/feature/auth/infrastructure/in_memory_auth_repository.dart`, cambiar la línea del `signIn`:

```dart
final user = AppUser(id: 'usr-jair', email: email.trim());
```

Esto alinea el id del usuario logueado en demo con el `usr-jair` de la lista de usuarios, haciendo que `UsersContentView` lo encuentre y le asigne el rol `master`.

- [ ] **Step 5: Verificar que no hay errores**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter analyze
```

Resultado esperado: sin errores nuevos (puede haber warnings existentes).

- [ ] **Step 6: Commit**

```bash
git add lib/feature/users/domain/entities/panel_user.dart \
        lib/feature/users/infrastructure/in_memory_users_repository.dart \
        lib/feature/auth/infrastructure/in_memory_auth_repository.dart \
        lib/presentation/users/bloc/users_state.dart
git commit -m "feat: add UserRole.master to role hierarchy"
```

---

## Task 2: UserModel — nuevos campos

**Files:**
- Modify: `lib/presentation/users/user_model.dart`

- [ ] **Step 1: Añadir `UserDeviceModel` y los nuevos campos a `UserModel`**

Reemplazar el bloque de `UserModel` y sus helpers en `lib/presentation/users/user_model.dart` con el siguiente contenido completo del archivo:

```dart
import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../feature/users/domain/entities/panel_user.dart';
import '../../feature/users/domain/entities/user_access_log.dart';
import '../widgets/user_list_tile.dart';
import 'bloc/users_state.dart';

// ── private helpers ───────────────────────────────────────────────────────────

const _avatarColors = [
  AppColors.primary,
  AppColors.secondary,
  AppColors.primaryBright,
];

String _roleLabel(UserRole role) => switch (role) {
      UserRole.master => 'Master',
      UserRole.admin  => 'Administrador',
      UserRole.viewer => 'Visualizador',
    };

String _formatRelative(DateTime? dt) {
  if (dt == null) return 'Nunca';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays == 1) return 'Ayer';
  return 'Hace ${diff.inDays} días';
}

String _formatDate(DateTime dt) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

String _formatLogTimestamp(DateTime dt) {
  final now = DateTime.now();
  final isToday =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  final isYesterday = DateTime(dt.year, dt.month, dt.day)
      .isAtSameMomentAs(DateTime(now.year, now.month, now.day - 1));
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  if (isToday) return 'Hoy $h:$m';
  if (isYesterday) return 'Ayer $h:$m';
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${dt.day} ${months[dt.month - 1]} $h:$m';
}

// Datos quemados de dispositivos — reemplazar cuando exista el endpoint.
final _demoDevices = [
  UserDeviceModel(label: 'Chrome · macOS', ip: '192.168.1.42'),
  UserDeviceModel(label: 'Firefox · Win', ip: '10.0.0.5'),
];

// ── models ────────────────────────────────────────────────────────────────────

class UserDeviceModel {
  UserDeviceModel({required this.label, required this.ip});

  final String label;
  final String ip;
}

/// UI representation of a [PanelUser] — feeds [UserListTile] and [UserDetailCard].
class UserModel {
  UserModel({
    required this.userId,
    required this.name,
    required this.role,
    required this.rawRole,
    required this.email,
    required this.createdAt,
    required this.onlineStatus,
    required this.lastSeen,
    required this.avatarColor,
    required this.devices,
  });

  final String userId;
  final String name;
  final String role;
  final UserRole rawRole;
  final String email;
  final String createdAt;
  final UserOnlineStatus onlineStatus;
  final String lastSeen;
  final Color avatarColor;
  final List<UserDeviceModel> devices;
}

/// UI representation of a [UserAccessLog] — feeds the access log rows.
class AccessLogModel {
  AccessLogModel({
    required this.user,
    required this.action,
    required this.timestamp,
    required this.color,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;
}

/// UI-ready stats for the session summary card and the online badge.
class UsersSessionModel {
  UsersSessionModel({
    required this.onlineLabel,
    required this.total,
    required this.online,
    required this.admins,
    required this.viewers,
  });

  final String onlineLabel;
  final String total;
  final String online;
  final String admins;
  final String viewers;
}

// ── extensions ────────────────────────────────────────────────────────────────

extension UserModelX on PanelUser {
  UserModel toModel(int index, {required bool isOnline}) => UserModel(
        userId: id,
        name: displayName,
        role: _roleLabel(role),
        rawRole: role,
        email: email,
        createdAt: _formatDate(createdAt),
        onlineStatus: isOnline ? UserOnlineStatus.online : UserOnlineStatus.offline,
        lastSeen: _formatRelative(lastLogin),
        avatarColor: _avatarColors[index % _avatarColors.length],
        devices: _demoDevices,
      );
}

extension AccessLogModelX on UserAccessLog {
  AccessLogModel toModel() => AccessLogModel(
        user: displayName,
        action: action == UserAccessAction.login
            ? 'Inicio de sesión'
            : 'Cierre de sesión',
        timestamp: _formatLogTimestamp(timestamp),
        color: action == UserAccessAction.login
            ? AppColors.primary
            : AppColors.textSecondary,
      );
}

extension UsersSessionModelX on UsersLoaded {
  UsersSessionModel toSessionModel() => UsersSessionModel(
        onlineLabel: '$onlineCount en línea',
        total: '${users.length}',
        online: '$onlineCount',
        admins: '$adminCount',
        viewers: '$viewerCount',
      );
}
```

- [ ] **Step 2: Verificar que no hay errores**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter analyze
```

Resultado esperado: sin errores nuevos.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/users/user_model.dart
git commit -m "feat: extend UserModel with email, createdAt, devices, rawRole, userId"
```

---

## Task 3: UsersBloc — método `changeRole` (optimista)

**Files:**
- Modify: `lib/presentation/users/bloc/users_bloc.dart`

- [ ] **Step 1: Añadir el método `changeRole` al Cubit**

Al final de la clase `UsersBloc`, antes del `@override Future<void> close()`, añadir:

```dart
void changeRole(String userId, UserRole newRole) {
  _users = [
    for (final u in _users)
      if (u.id == userId)
        PanelUser(
          id: u.id,
          email: u.email,
          displayName: u.displayName,
          role: newRole,
          lastLogin: u.lastLogin,
          sessionExpiresAt: u.sessionExpiresAt,
          createdAt: u.createdAt,
        )
      else
        u,
  ];
  _emitLoaded();
}
```

Asegurarse de que el import de `PanelUser` ya está en el archivo (ya existe: `import '../../../feature/users/domain/entities/panel_user.dart';`).

- [ ] **Step 2: Verificar**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/users/bloc/users_bloc.dart
git commit -m "feat: add optimistic changeRole to UsersBloc"
```

---

## Task 4: UserDetailCard — test primero, luego implementación

**Files:**
- Create: `test/presentation/users/widgets/user_detail_card_test.dart`
- Create: `lib/presentation/users/widgets/user_detail_card.dart`

- [ ] **Step 1: Crear el archivo de tests**

Crear `test/presentation/users/widgets/user_detail_card_test.dart`:

```dart
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
    devices: [UserDeviceModel(label: 'Chrome · macOS', ip: '10.0.0.1')],
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
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.viewer,
        targetRole: UserRole.viewer,
      ));
      expect(find.text('Ana García'), findsOneWidget);
    });

    testWidgets('muestra el email del usuario', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.viewer,
        targetRole: UserRole.viewer,
      ));
      expect(find.text('ana@test.com'), findsOneWidget);
    });

    testWidgets('admin ve botón Hacer Admin sobre viewer', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.admin,
        targetRole: UserRole.viewer,
      ));
      expect(find.text('Hacer Admin'), findsOneWidget);
    });

    testWidgets('viewer NO ve botón Hacer Admin sobre viewer', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.viewer,
        targetRole: UserRole.viewer,
      ));
      expect(find.text('Hacer Admin'), findsNothing);
    });

    testWidgets('master ve botón Quitar Admin sobre admin', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.master,
        targetRole: UserRole.admin,
      ));
      expect(find.text('Quitar Admin'), findsOneWidget);
    });

    testWidgets('admin NO ve botón Quitar Admin sobre admin', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.admin,
        targetRole: UserRole.admin,
      ));
      expect(find.text('Quitar Admin'), findsNothing);
    });

    testWidgets('no muestra acciones sobre perfil propio', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.master,
        targetRole: UserRole.viewer,
        currentUserId: 'mismo-usuario',
        targetUserId: 'mismo-usuario',
      ));
      expect(find.text('Hacer Admin'), findsNothing);
      expect(find.text('Quitar Admin'), findsNothing);
    });

    testWidgets('master ve Hacer Admin Y Quitar Admin según el rol del target', (tester) async {
      await tester.pumpWidget(_buildCard(
        currentUserRole: UserRole.master,
        targetRole: UserRole.viewer,
      ));
      expect(find.text('Hacer Admin'), findsOneWidget);
      expect(find.text('Quitar Admin'), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Ejecutar los tests — deben fallar (archivo no existe)**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter test test/presentation/users/widgets/user_detail_card_test.dart
```

Resultado esperado: error de compilación — `user_detail_card.dart` no existe.

- [ ] **Step 3: Crear `UserDetailCard`**

Crear `lib/presentation/users/widgets/user_detail_card.dart`:

```dart
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
```

- [ ] **Step 4: Ejecutar los tests — deben pasar**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter test test/presentation/users/widgets/user_detail_card_test.dart --reporter expanded
```

Resultado esperado: 8 tests, todos en verde (`✓`).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/users/widgets/user_detail_card.dart \
        test/presentation/users/widgets/user_detail_card_test.dart
git commit -m "feat: add UserDetailCard widget with role-based action buttons"
```

---

## Task 5: showUserDetailSheet

**Files:**
- Create: `lib/presentation/users/widgets/user_detail_sheet.dart`

- [ ] **Step 1: Crear la función**

Crear `lib/presentation/users/widgets/user_detail_sheet.dart`:

```dart
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
```

- [ ] **Step 2: Verificar**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/users/widgets/user_detail_sheet.dart
git commit -m "feat: add showUserDetailSheet (dialog/bottom sheet adaptive)"
```

---

## Task 6: Conectar todo — UsersList y UsersContentView

**Files:**
- Modify: `lib/presentation/users/widgets/users_list.dart`
- Modify: `lib/presentation/users/views/users_content_view.dart`

- [ ] **Step 1: Actualizar `UsersList` — nuevos parámetros y tap**

Reemplazar `lib/presentation/users/widgets/users_list.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../feature/users/domain/entities/panel_user.dart';
import '../../widgets/user_list_tile.dart';
import '../user_model.dart';
import 'user_detail_sheet.dart';

class UsersList extends StatelessWidget {
  const UsersList({
    super.key,
    required this.users,
    required this.currentUserRole,
    required this.currentUserId,
  });

  final List<UserModel> users;
  final UserRole currentUserRole;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Sin usuarios registrados',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Column(
      children: List.generate(users.length, (i) {
        final m = users[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i < users.length - 1 ? 12 : 0),
          child: GestureDetector(
            onTap: () => showUserDetailSheet(
              context: context,
              model: m,
              currentUserRole: currentUserRole,
              currentUserId: currentUserId,
            ),
            child: UserListTile(
              name: m.name,
              role: m.role,
              onlineStatus: m.onlineStatus,
              lastSeen: m.lastSeen,
              avatarColor: m.avatarColor,
            ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 2: Actualizar `UsersContentView` — derivar rol del usuario en sesión**

Reemplazar `lib/presentation/users/views/users_content_view.dart`:

```dart
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
    // Derivar rol del usuario en sesión buscando su PanelUser por id.
    final authState = context.watch<AuthBloc>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';
    final currentUserRole = state.users
            .where((u) => u.id == currentUserId)
            .firstOrNull
            ?.role ??
        UserRole.viewer;

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
```

- [ ] **Step 3: Verificar compilación**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter analyze
```

Resultado esperado: sin errores.

- [ ] **Step 4: Correr todos los tests**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel && flutter test
```

Resultado esperado: todos en verde.

- [ ] **Step 5: Commit final**

```bash
git add lib/presentation/users/widgets/users_list.dart \
        lib/presentation/users/views/users_content_view.dart
git commit -m "feat: wire user detail dialog — tap on tile opens adaptive detail sheet"
```

---

## Verificación manual

Después de la implementación, verificar en el emulador/dispositivo:

1. **Demo (sin credenciales):** `flutter run` → ir a `/users` → tocar cualquier tile → dialog/sheet se abre con nombre, email, fecha de registro y dispositivos.
2. **Botones visibles:** El usuario demo logueado es `usr-jair` (master) → todos los tiles de viewer deben mostrar "Hacer Admin", todos los de admin deben mostrar "Quitar Admin". El propio tile de Jair no muestra ningún botón.
3. **Breakpoints:** En ventana ancha (≥768px) aparece dialog centrado; en ventana estrecha (<768px) aparece bottom sheet con handle deslizable.
4. **Cambio optimista:** Tocar "Hacer Admin" en un viewer → dialog se cierra → tile actualiza el role en la lista sin reload.
