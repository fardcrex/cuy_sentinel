# User Detail Dialog — Design Spec
_2026-05-23_

## Contexto

Al hacer tap en un `UserListTile` de la pantalla de Usuarios, se abre un panel de
detalle con la información completa del usuario. En mobile aparece como bottom sheet
(deslizable desde abajo); en tablet/desktop aparece como dialog centrado.

---

## Modelo de datos

### Cambios en `UserModel`

Se añaden tres campos:

| Campo | Tipo | Origen |
|-------|------|--------|
| `email` | `String` | `PanelUser.email` |
| `createdAt` | `String` | `PanelUser.createdAt` formateado ("12 ene 2025") |
| `devices` | `List<UserDeviceModel>` | quemado en `toModel()` hasta que exista el backend |

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
showUserDetailSheet(BuildContext context, UserModel model)
```

Lee `MediaQuery.of(context).size.width`:
- `< 768` → `showModalBottomSheet`
- `>= 768` → `showDialog`

Archivo: `lib/presentation/users/widgets/user_detail_sheet.dart`

### Widget de contenido compartido

```
UserDetailCard(UserModel model, {required bool isBottomSheet})
```

`isBottomSheet` controla el border radius del contenedor:
- `true` → `BorderRadius.vertical(top: Radius.circular(24))`
- `false` → `BorderRadius.circular(16)`

Archivo: `lib/presentation/users/widgets/user_detail_card.dart`

### Árbol de componentes

```
UsersList
└── GestureDetector(onTap: showUserDetailSheet)
    └── UserListTile  (sin modificaciones internas)

showUserDetailSheet
    ├── mobile  → showModalBottomSheet → UserDetailCard(isBottomSheet: true)
    └── tablet+ → showDialog          → UserDetailCard(isBottomSheet: false)

UserDetailCard
    ├── _UserDetailHeader   (avatar, nombre, badge online/offline)
    ├── _UserDetailInfoRow  (email, rol, registrado, último acceso)
    └── _UserDetailDevices  (lista quemada: label + ip)
```

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
│  [icon]  Administrador / Visualizador   │  ← info rows
│  [icon]  Registrado: 12 ene 2025        │
│  [icon]  Último acceso: Hace 3 min      │
├─────────────────────────────────────────┤
│  DISPOSITIVOS ACTIVOS                   │
│  ● Chrome · macOS     192.168.1.42      │  ← devices (quemado)
│  ● Firefox · Win      10.0.0.5          │
└─────────────────────────────────────────┘
```

Íconos: `Icons.email_outlined`, `Icons.person_outline_rounded`,
`Icons.calendar_today_outlined`, `Icons.access_time_rounded`,
`Icons.devices_rounded`.

Colores: fondo `AppColors.panel`, stroke `AppColors.stroke`,
texto primario `AppColors.textPrimary`, secundario `AppColors.textSecondary`.

---

## Archivos modificados / creados

| Acción | Archivo |
|--------|---------|
| Modificado | `lib/presentation/users/user_model.dart` |
| Modificado | `lib/presentation/users/widgets/users_list.dart` |
| Nuevo | `lib/presentation/users/widgets/user_detail_card.dart` |
| Nuevo | `lib/presentation/users/widgets/user_detail_sheet.dart` |

`UserListTile` no se modifica — el tap lo maneja `UsersList` con un
`GestureDetector` envolviendo cada tile.

---

## Fuera de alcance (este sprint)

- Acciones sobre el usuario (cambiar rol, forzar logout)
- Datos reales de dispositivos/sesiones activas desde el backend
- Historial de accesos dentro del dialog
