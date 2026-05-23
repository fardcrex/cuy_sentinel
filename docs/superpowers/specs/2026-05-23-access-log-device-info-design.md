# Spec: Device Info en Access Logs

**Fecha:** 2026-05-23
**Proyecto:** cuy_sentinel
**Alcance:** Agregar dispositivo al flujo completo de accesos — BD → dominio → servicio → UI

---

## Contexto

La tarjeta "Accesos recientes" en la página de usuarios actualmente muestra usuario, acción y hora. Se refactoriza para incluir el dispositivo desde el que se inició/cerró sesión (plataforma + nombre). IP se mantiene como `null` en Fase 1 (captura planeada para Fase 2 vía headers de API Node.js).

---

## Decisiones de diseño

| Pregunta | Decisión |
|---|---|
| IP en Fase 1 | `null` — se captura en Fase 2 desde headers |
| Nivel de detalle del dispositivo | Medio: `Chrome 124 · macOS Sonoma`, `Pixel 7 · Android 14` |
| Layout de la tarjeta | Chip inline al lado de la acción (opción B) |
| Íconos de plataforma | `CustomPainter` rellenos teal para los 7 casos |
| Dónde colectar device info | `DeviceInfoService` inyectado en `LogAccessUseCase` |

---

## 1. Migración de BD

Agregar dos columnas opcionales a `user_access_logs`:

```sql
ALTER TABLE user_access_logs
  ADD COLUMN IF NOT EXISTS device_name     TEXT,
  ADD COLUMN IF NOT EXISTS device_platform TEXT;
```

`device_platform` toma uno de: `web`, `android`, `ios`, `macos`, `windows`, `linux`.
Registros históricos quedan con `NULL` — el chip simplemente no aparece en la UI.

---

## 2. Dominio — `UserAccessLog`

Agregar dos campos opcionales a la entidad:

```dart
final String? deviceName;      // "Chrome 124 · macOS Sonoma"
final String? devicePlatform;  // "web" | "android" | "ios" | "macos" | "windows" | "linux"
```

`fromJson` y `toJson` actualizados en consecuencia. `ipAddress` permanece como estaba.

---

## 3. Servicio — `DeviceInfoService`

**Archivo:** `lib/core/services/device_info_service.dart`

Interfaz + implementación que envuelve `device_info_plus`:

```dart
abstract interface class IDeviceInfoService {
  Future<({String deviceName, String devicePlatform})> getDeviceInfo();
}
```

Lógica por plataforma (`Platform` + `DeviceInfoPlugin`):

| Plataforma | `deviceName` | `devicePlatform` |
|---|---|---|
| Web | `"$browserName · $osName"` | `"web"` |
| Android | `"$model · Android $version"` | `"android"` |
| iOS | `"$name · iOS $systemVersion"` | `"ios"` |
| macOS | `"$computerName · macOS $majorMinor"` | `"macos"` |
| Windows | `"$computerName · Windows $majorVersion"` | `"windows"` |
| Linux | `"$prettyName"` | `"linux"` |

`InMemoryDeviceInfoService implements IDeviceInfoService` retorna datos fijos (`"Chrome 124 · macOS Sonoma"` / `"web"`) para modo demo sin dispositivo real.

---

## 4. Caso de uso — `LogAccessUseCase`

`IDeviceInfoService` se inyecta vía constructor. `execute()` llama `getDeviceInfo()` internamente antes de invocar `logAccess`. La firma pública de `execute()` no cambia — `AuthBloc` no se modifica.

```dart
class LogAccessUseCase {
  LogAccessUseCase(this._repository, this._deviceInfo);
  // execute() → getDeviceInfo() → logAccess(deviceName, devicePlatform)
}
```

---

## 5. Repositorio

**`IUsersRepository.logAccess`** — firma extendida con dos parámetros opcionales:

```dart
Future<void> logAccess({
  required String userId,
  required String displayName,
  required UserAccessAction action,
  String? deviceName,
  String? devicePlatform,
});
```

**`SupabaseUsersRepository`** — escribe `device_name` y `device_platform` en el INSERT.

**`InMemoryUsersRepository`** — acepta parámetros, los ignora. Data semilla hardcodeada incluye `deviceName`/`devicePlatform` representativos.

**`NodeUsersRepository`** — acepta parámetros, los ignora (sin cambio de comportamiento).

---

## 6. Inyección de dependencias

`IDeviceInfoService` se registra como singleton en:
- `phase1_dependencies.dart` → `DeviceInfoService` (real)
- `demo_dependencies.dart` → `InMemoryDeviceInfoService` (datos fijos)
- `phase2_dependencies.dart` → `DeviceInfoService` (real)

`LogAccessUseCase` recibe `IDeviceInfoService` en su constructor en todos los módulos.

---

## 7. UI

### `AccessLogModel`

Dos campos nuevos:

```dart
final String? deviceLabel;    // "Chrome 124 · macOS Sonoma"
final String? devicePlatform; // para elegir painter
```

`AccessLogModelX.toModel()` mapea desde `UserAccessLog`.

### `PlatformIconPainter` (CustomPainter)

**Archivo:** `lib/presentation/widgets/platform_icon_painter.dart`

Un `CustomPainter` por plataforma, todos con `Paint()..style = PaintingStyle.fill` en `AppColors.primary`. Cortes internos pintados en el color de fondo del contexto.

| Plataforma | Diseño |
|---|---|
| `web` | Globo con meridianos cortados |
| `android` | Robot con antenas, ojos y brazos |
| `ios` | Manzana con mordisco (`Path.combine(difference)`) + hoja |
| `macos` | Monitor con pantalla, cuello y base |
| `windows` | 4 polígonos en perspectiva |
| `linux` | Rectángulo relleno con `>_` cortado |
| null | Círculo con 4 puntos cortados |

Widget público: `PlatformIcon({required String? platform, double size = 16})`.

### `UsersLogEntry`

Layout B — chip inline al lado de la acción:

```
● Jair Conislla · Inicio de sesión  [🖥 Chrome 124 · macOS Sonoma]  Hoy 14:32
```

Si `deviceLabel` es `null`, el chip no aparece — backward compatible con logs históricos.

---

## 8. Data semilla (InMemory)

Los 5 logs existentes en `InMemoryUsersRepository` se actualizan para incluir `deviceName` y `devicePlatform` representativos (web, android, iOS).

---

## Archivos afectados

| Archivo | Cambio |
|---|---|
| `database/schema.sql` (go) | Agregar columnas `device_name`, `device_platform` |
| `feature/users/domain/entities/user_access_log.dart` | Nuevos campos |
| `core/services/device_info_service.dart` | **Nuevo** |
| `feature/users/application/get_users_use_case.dart` | `LogAccessUseCase` recibe `IDeviceInfoService` |
| `feature/users/domain/interfaces/i_users_repository.dart` | Firma `logAccess` extendida |
| `feature/users/infrastructure/supabase_users_repository.dart` | INSERT con nuevas columnas |
| `feature/users/infrastructure/in_memory_users_repository.dart` | Datos semilla + firma |
| `feature/users/infrastructure/node_users_repository.dart` | Firma actualizada |
| `core/injection/modules/users_module.dart` | Registrar `IDeviceInfoService` |
| `core/injection/envs/phase1_dependencies.dart` | Instancia real |
| `core/injection/envs/demo_dependencies.dart` | Instancia en memoria |
| `core/injection/envs/phase2_dependencies.dart` | Instancia real |
| `presentation/widgets/platform_icon_painter.dart` | **Nuevo** |
| `presentation/users/user_model.dart` | `AccessLogModel` + `toModel()` |
| `presentation/users/widgets/users_access_log_card.dart` | `UsersLogEntry` con chip |
| Supabase BD | Migración `ALTER TABLE user_access_logs` |
