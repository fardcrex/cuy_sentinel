# User Detail Dialog — Design Spec
_2026-05-23_

## Contexto

Al hacer tap en un `UserListTile` de la pantalla de Usuarios, se abre un panel de
detalle con la información completa del usuario. En mobile aparece como bottom sheet
(deslizable desde abajo); en tablet/desktop aparece como dialog centrado.

Un usuario admin o master puede promover a otro usuario a admin. Solo un master puede
degradar un admin a viewer.

---

## Jerarquía de roles

```
master  >  admin  >  viewer
```

| Rol | Puede "Hacer Admin" (viewer→admin) | Puede "Quitar Admin" (admin→viewer) |
|-----|------------------------------------|--------------------------------------|
| master | Sí | Sí |
| admin | Sí | No |
| viewer | No | No |

Los botones de acción **nunca aparecen sobre uno mismo** (un usuario no puede
cambiar su propio rol desde este dialog).

---

## Cambios en el dominio

### `UserRole` — nuevo valor `master`

```dart
enum UserRole {
  master,   // ← nuevo
  admin,
  viewer;
}
```

`UserRole.fromString` debe mapear `'master'` → `UserRole.master`.

### `AppUser` — añadir `role`

`AppUser` actualmente solo tiene `id` y `email`. Se añade `role: UserRole` para que
la sesión autenticada exponga el rol del usuario en sesión. Esto evita buscar al
usuario logueado dentro de la lista `UsersLoaded.users`.

### `UsersLoaded` — corrección de `adminCount`

El getter `adminCount` actualmente cuenta solo `UserRole.admin`. Debe incluir también
`UserRole.master` o bien exponer contadores separados según necesidad de la UI.

---

## Modelo de presentación

### Cambios en `UserModel`

Se añaden cinco campos nuevos:

| Campo | Tipo | Origen |
|-------|------|--------|
| `email` | `String` | `PanelUser.email` |
| `createdAt` | `String` | `PanelUser.createdAt` formateado ("12 ene 2025") |
| `devices` | `List<UserDeviceModel>` | quemado en `toModel()` hasta que exista el backend |
| `rawRole` | `UserRole` | `PanelUser.role` — necesario para las reglas de botones |
| `userId` | `String` | `PanelUser.id` — para comparar con el usuario en sesión |

### `UserDeviceModel` (nuevo, en `user_model.dart`)

```dart
class UserDeviceModel {
  final String label;  // "Chrome · macOS"
  final String ip;     // "192.168.1.42"
}
```

Los datos quemados representan los dispositivos activos de demo; serán reemplazados
cuando se implemente el endpoint de sesiones.

---

## Arquitectura

### Función de entrada

```
showUserDetailSheet(
  BuildContext context,
  UserModel model,
  UserRole currentUserRole,
)
```

- Obtiene `currentUserRole` desde `context.read<AuthBloc>().state` (cast a
  `AuthAuthenticated`).
- Lee `MediaQuery.of(context).size.width`:
  - `< 768` → `showModalBottomSheet`
  - `>= 768` → `showDialog`

Archivo: `lib/presentation/users/widgets/user_detail_sheet.dart`

### Widget de contenido compartido

```
UserDetailCard({
  required UserModel model,
  required UserRole currentUserRole,
  required bool isBottomSheet,
  VoidCallback? onPromoteToAdmin,
  VoidCallback? onDemoteToViewer,
})
```

`isBottomSheet` controla el border radius del contenedor:
- `true` → `BorderRadius.vertical(top: Radius.circular(24))`
- `false` → `BorderRadius.circular(16)`

Archivo: `lib/presentation/users/widgets/user_detail_card.dart`

### Árbol de componentes

```
UsersContentView
└── UsersList(currentUserRole: UserRole)
    └── GestureDetector(onTap: () => showUserDetailSheet(ctx, model, currentUserRole))
        └── UserListTile  (sin modificaciones internas)

showUserDetailSheet
    ├── mobile  → showModalBottomSheet → UserDetailCard(isBottomSheet: true)
    └── tablet+ → showDialog          → UserDetailCard(isBottomSheet: false)

UserDetailCard
    ├── _UserDetailHeader   (avatar, nombre, badge online/offline)
    ├── _UserDetailInfoRow  (email, rol, registrado, último acceso)
    ├── _UserDetailDevices  (lista quemada: label + ip)
    └── _UserDetailActions  (botones condicionales — ver reglas abajo)
```

### Reglas de visibilidad de botones (en `_UserDetailActions`)

```
val isOwnProfile = model.userId == currentUserId
val targetIsViewer = model.rawRole == UserRole.viewer
val targetIsAdmin  = model.rawRole == UserRole.admin

"Hacer Admin"  visible si: !isOwnProfile && (currentUserRole == admin || master) && targetIsViewer
"Quitar Admin" visible si: !isOwnProfile && currentUserRole == master && targetIsAdmin
```

Si ningún botón es visible, `_UserDetailActions` no se renderiza (sin sección vacía).

### Evento BLoC

Se añade un nuevo evento en `UsersBloc`:

```dart
final class ChangeUserRole extends UsersEvent {
  final String userId;
  final UserRole newRole;
}
```

El BLoC despacha este evento; la llamada al repositorio se implementa en un sprint
posterior. Por ahora el BLoC puede emitir un estado de "sin implementar" o simplemente
no hacer nada (el botón cierra el dialog).

---

## Comportamiento por breakpoint

### Mobile (`width < 768`) — `showModalBottomSheet`

| Parámetro | Valor |
|-----------|-------|
| `isScrollControlled` | `true` |
| `useSafeArea` | `true` |
| `backgroundColor` | `Colors.transparent` |
| Border radius | esquinas superiores `24` |
| Handle | drag handle estándar centrado |
| Altura | `intrinsicHeight` — ajustada al contenido |
| Barrier | `Colors.black54` |

### Tablet / Desktop (`width >= 768`) — `showDialog`

| Parámetro | Valor |
|-----------|-------|
| `barrierDismissible` | `true` |
| `maxWidth` | `420` |
| Border radius | `16` en todas las esquinas |
| Animación | fade + scale (default de `showDialog`) |
| Barrier | `Colors.black54` |

---

## Layout de `UserDetailCard`

```
┌─────────────────────────────────────────┐
│  [Avatar 52px]  Nombre completo         │  ← header
│                 Rol · badge online       │
├─────────────────────────────────────────┤
│  [icon]  email@ejemplo.com              │
│  [icon]  Master / Admin / Visualizador  │  ← info rows
│  [icon]  Registrado: 12 ene 2025        │
│  [icon]  Último acceso: Hace 3 min      │
├─────────────────────────────────────────┤
│  DISPOSITIVOS ACTIVOS                   │
│  ● Chrome · macOS     192.168.1.42      │  ← devices (quemado)
│  ● Firefox · Win      10.0.0.5          │
├─────────────────────────────────────────┤
│  [ Hacer Admin ]   (condicional)        │  ← actions (solo si aplica)
│  [ Quitar Admin ]  (condicional)        │
└─────────────────────────────────────────┘
```

**Estilo del botón "Hacer Admin":** `FilledButton` con color `AppColors.primary`.
**Estilo del botón "Quitar Admin":** `OutlinedButton` con color `AppColors.warning`.

Íconos de info rows: `Icons.email_outlined`, `Icons.shield_outlined`,
`Icons.calendar_today_outlined`, `Icons.access_time_rounded`,
`Icons.devices_rounded`.

Colores: fondo `AppColors.panel`, stroke `AppColors.stroke`,
texto primario `AppColors.textPrimary`, secundario `AppColors.textSecondary`.

---

## Archivos modificados / creados

| Acción | Archivo |
|--------|---------|
| Modificado | `lib/feature/users/domain/entities/panel_user.dart` — `UserRole.master` |
| Modificado | `lib/feature/auth/domain/entities/app_user.dart` — añadir `role` |
| Modificado | `lib/feature/auth/infrastructure/supabase_auth_repository.dart` — mapear `role` |
| Modificado | `lib/feature/auth/infrastructure/in_memory_auth_repository.dart` — mapear `role` |
| Modificado | `lib/presentation/auth/bloc/auth_state.dart` — `AppUser` tiene `role` |
| Modificado | `lib/presentation/users/user_model.dart` — +email, +createdAt, +devices, +rawRole, +userId |
| Modificado | `lib/presentation/users/views/users_content_view.dart` — pasar `currentUserRole` a `UsersList` |
| Modificado | `lib/presentation/users/widgets/users_list.dart` — recibir `currentUserRole`, añadir tap |
| Modificado | `lib/presentation/users/bloc/users_state.dart` — corregir `adminCount` con `master` |
| Modificado | `lib/presentation/users/bloc/users_event.dart` — añadir `ChangeUserRole` |
| Nuevo | `lib/presentation/users/widgets/user_detail_card.dart` |
| Nuevo | `lib/presentation/users/widgets/user_detail_sheet.dart` |

`UserListTile` no se modifica — el tap lo maneja `UsersList`.

---

## Fuera de alcance (este sprint)

- Persistencia real del cambio de rol en Supabase / backend
- Datos reales de dispositivos/sesiones activas
- Historial de accesos dentro del dialog
- Forzar logout desde el dialog
