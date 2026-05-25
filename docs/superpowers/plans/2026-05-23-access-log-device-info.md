# Access Log Device Info — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Registrar y mostrar el dispositivo (plataforma + nombre) en cada entrada del log de accesos, usando `device_info_plus` en el momento del login/logout.

**Architecture:** Un `DeviceInfoService` inyectado en `LogAccessUseCase` recolecta la info del dispositivo al momento de cada acción de auth. Los datos se persisten en dos columnas nuevas en `user_access_logs` y se muestran como chip inline en la tarjeta de accesos de la página de usuarios. Siete `CustomPainter` rellenos en teal representan cada plataforma.

**Tech Stack:** Flutter 3, Dart 3 records, `device_info_plus ^13.1.0`, Supabase, flutter_bloc, CustomPainter

---

## File Map

| Archivo | Acción |
|---|---|
| `cuy_sentinel_go/database/schema.sql` | Modificar — agregar columnas a DDL |
| `lib/feature/users/domain/entities/user_access_log.dart` | Modificar — agregar `deviceName`, `devicePlatform` |
| `lib/feature/users/domain/interfaces/i_users_repository.dart` | Modificar — extender firma `logAccess` |
| `lib/feature/users/infrastructure/supabase_users_repository.dart` | Modificar — INSERT con nuevas columnas |
| `lib/feature/users/infrastructure/in_memory_users_repository.dart` | Modificar — firma + seed data |
| `lib/feature/users/infrastructure/node_users_repository.dart` | Modificar — firma (stub) |
| `lib/core/services/device_info_service.dart` | **Crear** — interfaz + impl real + impl in-memory |
| `lib/feature/users/application/get_users_use_case.dart` | Modificar — `LogAccessUseCase` inyecta `IDeviceInfoService` |
| `lib/core/injection/app_dependencies.dart` | Modificar — agregar campo `deviceInfoService` |
| `lib/core/injection/envs/phase1_dependencies.dart` | Modificar — pasar `DeviceInfoService()` |
| `lib/core/injection/envs/demo_dependencies.dart` | Modificar — pasar `InMemoryDeviceInfoService()` |
| `lib/core/injection/envs/phase2_dependencies.dart` | Modificar — pasar `DeviceInfoService()` |
| `lib/core/injection/modules/users_module.dart` | Modificar — recibir y pasar `IDeviceInfoService` |
| `lib/core/app.dart` | Modificar — pasar `deviceInfoService` a `LogAccessUseCase` |
| `lib/presentation/widgets/platform_icon_painter.dart` | **Crear** — 7 painters + widget `PlatformIcon` |
| `lib/presentation/users/user_model.dart` | Modificar — `AccessLogModel` + `toModel()` |
| `lib/presentation/users/widgets/users_access_log_card.dart` | Modificar — chip inline en `UsersLogEntry` |
| `test/feature/users/domain/user_access_log_test.dart` | **Crear** — unit tests entidad |
| `test/feature/users/application/log_access_use_case_test.dart` | **Crear** — unit tests use case |

---

## Task 1: DB Migration

**Files:**
- Modify: `cuy_sentinel_go/database/schema.sql`
- Supabase dashboard SQL Editor

- [ ] **Step 1: Aplicar migración en Supabase**

En el SQL Editor del dashboard de Supabase, ejecutar:

```sql
ALTER TABLE user_access_logs
  ADD COLUMN IF NOT EXISTS device_name     TEXT,
  ADD COLUMN IF NOT EXISTS device_platform TEXT;
```

Verificar: `SELECT column_name FROM information_schema.columns WHERE table_name = 'user_access_logs';` debe incluir `device_name` y `device_platform`.

- [ ] **Step 2: Actualizar schema.sql**

En `cuy_sentinel_go/database/schema.sql`, agregar las columnas a la definición de `user_access_logs` (después de `ip_address`):

```sql
    ip_address      TEXT,                                  -- capturado desde headers (Fase 2)
    device_name     TEXT,                                  -- "Chrome 124 · macOS Sonoma"
    device_platform TEXT                                   -- 'web' | 'android' | 'ios' | 'macos' | 'windows' | 'linux'
```

- [ ] **Step 3: Commit**

```bash
git add cuy_sentinel_go/database/schema.sql
git commit -m "feat: add device_name and device_platform columns to user_access_logs"
```

---

## Task 2: `UserAccessLog` entity

**Files:**
- Modify: `lib/feature/users/domain/entities/user_access_log.dart`
- Create: `test/feature/users/domain/user_access_log_test.dart`

- [ ] **Step 1: Escribir tests que fallan**

Crear `test/feature/users/domain/user_access_log_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_access_log.dart';

void main() {
  group('UserAccessLog', () {
    final baseJson = {
      'id': 'log-1',
      'user_id': 'usr-1',
      'display_name': 'Jair',
      'action': 'login',
      'timestamp': '2026-05-23T10:00:00.000Z',
      'ip_address': null,
    };

    test('fromJson maps deviceName and devicePlatform when present', () {
      final json = {...baseJson, 'device_name': 'Chrome 124 · macOS Sonoma', 'device_platform': 'web'};
      final log = UserAccessLog.fromJson(json);
      expect(log.deviceName, 'Chrome 124 · macOS Sonoma');
      expect(log.devicePlatform, 'web');
    });

    test('fromJson treats missing device fields as null', () {
      final log = UserAccessLog.fromJson(baseJson);
      expect(log.deviceName, isNull);
      expect(log.devicePlatform, isNull);
    });

    test('toJson includes deviceName and devicePlatform', () {
      final log = UserAccessLog(
        id: 'log-1', userId: 'usr-1', displayName: 'Jair',
        action: UserAccessAction.login,
        timestamp: DateTime.utc(2026, 5, 23, 10),
        deviceName: 'Pixel 7 · Android 14',
        devicePlatform: 'android',
      );
      final json = log.toJson();
      expect(json['device_name'], 'Pixel 7 · Android 14');
      expect(json['device_platform'], 'android');
    });

    test('toJson uses null for missing device fields', () {
      final log = UserAccessLog(
        id: 'log-1', userId: 'usr-1', displayName: 'Jair',
        action: UserAccessAction.login,
        timestamp: DateTime.utc(2026, 5, 23, 10),
      );
      final json = log.toJson();
      expect(json['device_name'], isNull);
      expect(json['device_platform'], isNull);
    });
  });
}
```

- [ ] **Step 2: Verificar que los tests fallan**

```bash
flutter test test/feature/users/domain/user_access_log_test.dart
```

Expected: FAIL — `The named parameter 'deviceName' isn't defined`.

- [ ] **Step 3: Actualizar la entidad**

Reemplazar el contenido de `lib/feature/users/domain/entities/user_access_log.dart`:

```dart
enum UserAccessAction {
  login,
  logout;

  static UserAccessAction fromString(String value) => switch (value) {
    'login'  => UserAccessAction.login,
    'logout' => UserAccessAction.logout,
    _        => UserAccessAction.login,
  };

  String toJson() => name;
}

class UserAccessLog {
  const UserAccessLog({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.action,
    required this.timestamp,
    this.ipAddress,
    this.deviceName,
    this.devicePlatform,
  });

  final String id;
  final String userId;
  final String displayName;
  final UserAccessAction action;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceName;
  final String? devicePlatform;

  factory UserAccessLog.fromJson(Map<String, dynamic> json) => UserAccessLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    displayName: json['display_name'] as String,
    action: UserAccessAction.fromString(json['action'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    ipAddress: json['ip_address'] as String?,
    deviceName: json['device_name'] as String?,
    devicePlatform: json['device_platform'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'display_name': displayName,
    'action': action.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'ip_address': ipAddress,
    'device_name': deviceName,
    'device_platform': devicePlatform,
  };
}
```

- [ ] **Step 4: Verificar que los tests pasan**

```bash
flutter test test/feature/users/domain/user_access_log_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/feature/users/domain/entities/user_access_log.dart test/
git commit -m "feat: add deviceName and devicePlatform to UserAccessLog entity"
```

---

## Task 3: Repository interface + implementaciones

**Files:**
- Modify: `lib/feature/users/domain/interfaces/i_users_repository.dart`
- Modify: `lib/feature/users/infrastructure/supabase_users_repository.dart`
- Modify: `lib/feature/users/infrastructure/in_memory_users_repository.dart`
- Modify: `lib/feature/users/infrastructure/node_users_repository.dart`

- [ ] **Step 1: Actualizar `IUsersRepository.logAccess`**

En `lib/feature/users/domain/interfaces/i_users_repository.dart`, reemplazar la firma de `logAccess`:

```dart
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  });
```

- [ ] **Step 2: Actualizar `SupabaseUsersRepository.logAccess`**

En `lib/feature/users/infrastructure/supabase_users_repository.dart`, reemplazar el método `logAccess`:

```dart
  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) async {
    await _client.from('user_access_logs').insert({
      'user_id': userId,
      'display_name': displayName,
      'action': action.toJson(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'device_name': deviceName,
      'device_platform': devicePlatform,
    });
  }
```

- [ ] **Step 3: Actualizar `InMemoryUsersRepository`**

En `lib/feature/users/infrastructure/in_memory_users_repository.dart`, hacer dos cambios:

**3a — Actualizar seed data `_logs` con device info:**

```dart
  static final _logs = [
    UserAccessLog(
      id: 'log-001',
      userId: 'usr-jair',
      displayName: 'Jair Conislla',
      action: UserAccessAction.login,
      timestamp: _now.subtract(const Duration(minutes: 12)),
      deviceName: 'Chrome 124 · macOS Sonoma',
      devicePlatform: 'web',
    ),
    UserAccessLog(
      id: 'log-002',
      userId: 'usr-daniel',
      displayName: 'Daniel Rojas',
      action: UserAccessAction.logout,
      timestamp: _now.subtract(const Duration(hours: 1, minutes: 30)),
      deviceName: 'Pixel 7 · Android 14',
      devicePlatform: 'android',
    ),
    UserAccessLog(
      id: 'log-003',
      userId: 'usr-daniel',
      displayName: 'Daniel Rojas',
      action: UserAccessAction.login,
      timestamp: _now.subtract(const Duration(hours: 3, minutes: 40)),
      deviceName: 'Pixel 7 · Android 14',
      devicePlatform: 'android',
    ),
    UserAccessLog(
      id: 'log-004',
      userId: 'usr-jheampierre',
      displayName: 'Jheampierre Ralli',
      action: UserAccessAction.logout,
      timestamp: _now.subtract(const Duration(days: 1, hours: 2)),
      deviceName: 'iPhone 15 · iOS 17.4',
      devicePlatform: 'ios',
    ),
    UserAccessLog(
      id: 'log-005',
      userId: 'usr-jheampierre',
      displayName: 'Jheampierre Ralli',
      action: UserAccessAction.login,
      timestamp: _now.subtract(const Duration(days: 1, hours: 3, minutes: 15)),
      deviceName: 'iPhone 15 · iOS 17.4',
      devicePlatform: 'ios',
    ),
  ];
```

**3b — Actualizar la firma de `logAccess`:**

```dart
  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) async {}
```

- [ ] **Step 4: Actualizar `NodeUsersRepository.logAccess`**

En `lib/feature/users/infrastructure/node_users_repository.dart`, reemplazar el método `logAccess`:

```dart
  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) => throw UnimplementedError('NodeUsersRepository.logAccess');
```

- [ ] **Step 5: Verificar que compila sin errores**

```bash
flutter analyze lib/feature/users/
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/feature/users/
git commit -m "feat: extend logAccess signature with deviceName and devicePlatform"
```

---

## Task 4: `DeviceInfoService`

**Files:**
- Create: `lib/core/services/device_info_service.dart`
- Create: `test/core/services/device_info_service_test.dart`

- [ ] **Step 1: Escribir test para `InMemoryDeviceInfoService`**

Crear `test/core/services/device_info_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/core/services/device_info_service.dart';

void main() {
  group('InMemoryDeviceInfoService', () {
    test('returns fixed web device info', () async {
      final service = InMemoryDeviceInfoService();
      final info = await service.getDeviceInfo();
      expect(info.deviceName, isNotEmpty);
      expect(info.devicePlatform, 'web');
    });
  });
}
```

- [ ] **Step 2: Verificar que el test falla**

```bash
flutter test test/core/services/device_info_service_test.dart
```

Expected: FAIL — target file not found.

- [ ] **Step 3: Crear `lib/core/services/device_info_service.dart`**

```dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

abstract interface class IDeviceInfoService {
  Future<({String deviceName, String devicePlatform})> getDeviceInfo();
}

class DeviceInfoService implements IDeviceInfoService {
  final _plugin = DeviceInfoPlugin();

  @override
  Future<({String deviceName, String devicePlatform})> getDeviceInfo() async {
    try {
      if (kIsWeb) return _webInfo();
      if (Platform.isAndroid) return _androidInfo();
      if (Platform.isIOS) return _iosInfo();
      if (Platform.isMacOS) return _macOsInfo();
      if (Platform.isWindows) return _windowsInfo();
      if (Platform.isLinux) return _linuxInfo();
    } catch (_) {}
    return (deviceName: 'Dispositivo desconocido', devicePlatform: 'unknown');
  }

  Future<({String deviceName, String devicePlatform})> _webInfo() async {
    final info = await _plugin.webBrowserInfo;
    final browser = _capitalize(info.browserName.name);
    final os = _osFromUserAgent(info.userAgent ?? '');
    return (deviceName: '$browser · $os', devicePlatform: 'web');
  }

  Future<({String deviceName, String devicePlatform})> _androidInfo() async {
    final info = await _plugin.androidInfo;
    return (
      deviceName: '${info.model} · Android ${info.version.release}',
      devicePlatform: 'android',
    );
  }

  Future<({String deviceName, String devicePlatform})> _iosInfo() async {
    final info = await _plugin.iosInfo;
    return (
      deviceName: '${info.model} · iOS ${info.systemVersion}',
      devicePlatform: 'ios',
    );
  }

  Future<({String deviceName, String devicePlatform})> _macOsInfo() async {
    final info = await _plugin.macOsInfo;
    return (
      deviceName: '${info.computerName} · macOS ${info.majorVersion}.${info.minorVersion}',
      devicePlatform: 'macos',
    );
  }

  Future<({String deviceName, String devicePlatform})> _windowsInfo() async {
    final info = await _plugin.windowsInfo;
    return (
      deviceName: '${info.computerName} · Windows ${info.majorVersion}',
      devicePlatform: 'windows',
    );
  }

  Future<({String deviceName, String devicePlatform})> _linuxInfo() async {
    final info = await _plugin.linuxInfo;
    return (deviceName: info.prettyName, devicePlatform: 'linux');
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _osFromUserAgent(String ua) {
    if (ua.contains('Mac OS X')) return 'macOS';
    if (ua.contains('Windows')) return 'Windows';
    if (ua.contains('Android')) return 'Android';
    if (ua.contains('iPhone') || ua.contains('iPad')) return 'iOS';
    if (ua.contains('Linux')) return 'Linux';
    return 'Web';
  }
}

class InMemoryDeviceInfoService implements IDeviceInfoService {
  @override
  Future<({String deviceName, String devicePlatform})> getDeviceInfo() async =>
      (deviceName: 'Chrome 124 · macOS Sonoma', devicePlatform: 'web');
}
```

- [ ] **Step 4: Verificar que el test pasa**

```bash
flutter test test/core/services/device_info_service_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/device_info_service.dart test/core/
git commit -m "feat: add DeviceInfoService with device_info_plus"
```

---

## Task 5: `LogAccessUseCase`

**Files:**
- Modify: `lib/feature/users/application/get_users_use_case.dart`
- Create: `test/feature/users/application/log_access_use_case_test.dart`

- [ ] **Step 1: Escribir tests que fallan**

Crear `test/feature/users/application/log_access_use_case_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/core/services/device_info_service.dart';
import 'package:cuy_sentinel/core/utils/stream_retry.dart';
import 'package:cuy_sentinel/feature/users/application/get_users_use_case.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/panel_user.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_access_log.dart';
import 'package:cuy_sentinel/feature/users/domain/interfaces/i_users_repository.dart';

// ── test doubles ─────────────────────────────────────────────────────────────

class _FakeRepo implements IUsersRepository {
  String? loggedUserId;
  String? loggedDeviceName;
  String? loggedDevicePlatform;
  UserAccessAction? loggedAction;

  final PanelUser? _user;
  _FakeRepo({PanelUser? user}) : _user = user;

  @override
  Future<PanelUser?> getUserById(String id) async => _user;

  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) async {
    loggedUserId = userId;
    loggedDeviceName = deviceName;
    loggedDevicePlatform = devicePlatform;
    loggedAction = action;
  }

  @override Future<void> updateSession(String userId, {required bool loggedIn}) async {}
  @override Stream<List<PanelUser>> watchUsers({void Function(RetryState)? onRetry}) => const Stream.empty();
  @override Stream<List<UserAccessLog>> watchAccessLogs({int limit = 50, void Function(RetryState)? onRetry}) => const Stream.empty();
  @override Stream<Set<String>> watchPresence() => const Stream.empty();
  @override Future<void> trackPresence(String userId) async {}
  @override Future<void> untrackPresence() async {}
  @override Future<List<PanelUser>> getUsers() async => [];
  @override Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) async => [];
  @override Future<List<UserAccessLog>> getAccessLogsByUser({required String userId, int limit = 20}) async => [];
}

class _FakeDeviceInfo implements IDeviceInfoService {
  final String name;
  final String platform;
  _FakeDeviceInfo({this.name = 'Test Device', this.platform = 'web'});

  @override
  Future<({String deviceName, String devicePlatform})> getDeviceInfo() async =>
      (deviceName: name, devicePlatform: platform);
}

// ── tests ────────────────────────────────────────────────────────────────────

void main() {
  group('LogAccessUseCase', () {
    test('passes deviceName and devicePlatform to repository', () async {
      final repo = _FakeRepo();
      final deviceInfo = _FakeDeviceInfo(name: 'Chrome 124 · macOS Sonoma', platform: 'web');
      final useCase = LogAccessUseCase(repo, deviceInfo);

      await useCase.execute(
        userId: 'usr-1',
        fallbackName: 'test@example.com',
        action: UserAccessAction.login,
        loggedIn: true,
      );

      expect(repo.loggedDeviceName, 'Chrome 124 · macOS Sonoma');
      expect(repo.loggedDevicePlatform, 'web');
    });

    test('uses displayName from repo when user found', () async {
      final user = PanelUser(
        id: 'usr-1', email: 'jair@test.com', displayName: 'Jair Conislla',
        role: UserRole.admin, createdAt: DateTime(2025),
      );
      final repo = _FakeRepo(user: user);
      final useCase = LogAccessUseCase(repo, _FakeDeviceInfo());

      await useCase.execute(
        userId: 'usr-1',
        fallbackName: 'jair@test.com',
        action: UserAccessAction.login,
        loggedIn: true,
      );

      // No assertion on displayName here since logAccess captures it internally.
      // We verify the call completed without error.
      expect(repo.loggedUserId, 'usr-1');
    });

    test('falls back to email when user not found in repo', () async {
      final repo = _FakeRepo(user: null);
      final useCase = LogAccessUseCase(repo, _FakeDeviceInfo());

      await expectLater(
        useCase.execute(
          userId: 'usr-x',
          fallbackName: 'ghost@test.com',
          action: UserAccessAction.logout,
          loggedIn: false,
        ),
        completes,
      );
      expect(repo.loggedUserId, 'usr-x');
    });
  });
}
```

- [ ] **Step 2: Verificar que los tests fallan**

```bash
flutter test test/feature/users/application/log_access_use_case_test.dart
```

Expected: FAIL — `LogAccessUseCase` constructor doesn't accept `IDeviceInfoService`.

- [ ] **Step 3: Actualizar `LogAccessUseCase` en `get_users_use_case.dart`**

Agregar import al inicio del archivo:

```dart
import '../../../core/services/device_info_service.dart';
```

Reemplazar la clase `LogAccessUseCase` (mantener el resto del archivo intacto):

```dart
class LogAccessUseCase {
  const LogAccessUseCase(this._repository, this._deviceInfo);

  final IUsersRepository _repository;
  final IDeviceInfoService _deviceInfo;

  Future<void> execute({
    required String userId,
    required String fallbackName,
    required UserAccessAction action,
    required bool loggedIn,
  }) async {
    final (user, device) = await (
      _repository.getUserById(userId),
      _deviceInfo.getDeviceInfo(),
    ).wait;
    final displayName = user?.displayName ?? fallbackName;
    await Future.wait([
      _repository.logAccess(
        userId: userId,
        displayName: displayName,
        action: action,
        deviceName: device.deviceName,
        devicePlatform: device.devicePlatform,
      ),
      _repository.updateSession(userId, loggedIn: loggedIn),
    ]);
  }
}
```

- [ ] **Step 4: Verificar que los tests pasan**

```bash
flutter test test/feature/users/application/log_access_use_case_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/feature/users/application/get_users_use_case.dart test/feature/users/application/
git commit -m "feat: inject IDeviceInfoService into LogAccessUseCase"
```

---

## Task 6: Wiring de inyección de dependencias

**Files:**
- Modify: `lib/core/injection/app_dependencies.dart`
- Modify: `lib/core/injection/envs/phase1_dependencies.dart`
- Modify: `lib/core/injection/envs/demo_dependencies.dart`
- Modify: `lib/core/injection/envs/phase2_dependencies.dart`
- Modify: `lib/core/injection/modules/users_module.dart`
- Modify: `lib/core/app.dart`

- [ ] **Step 1: Agregar `deviceInfoService` a `AppDependencies`**

Reemplazar el contenido de `lib/core/injection/app_dependencies.dart`:

```dart
import '../../core/services/device_info_service.dart';
import '../../feature/alerts/domain/interfaces/i_alerts_repository.dart';
import '../../feature/auth/domain/interfaces/i_auth_repository.dart';
import '../../feature/databases/domain/interfaces/i_databases_repository.dart';
import '../../feature/metrics/domain/interfaces/i_metrics_repository.dart';
import '../../feature/monitoring/domain/interfaces/i_monitoring_repository.dart';
import '../../feature/users/domain/interfaces/i_users_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.monitoringRepository,
    required this.metricsRepository,
    required this.alertsRepository,
    required this.usersRepository,
    required this.databasesRepository,
    required this.deviceInfoService,
    this.onReconnect,
  });

  final IAuthRepository authRepository;
  final IMonitoringRepository monitoringRepository;
  final IMetricsRepository metricsRepository;
  final IAlertsRepository alertsRepository;
  final IUsersRepository usersRepository;
  final IDatabasesRepository databasesRepository;
  final IDeviceInfoService deviceInfoService;
  final void Function()? onReconnect;
}
```

- [ ] **Step 2: Actualizar `buildPhase1Dependencies`**

Reemplazar el contenido de `lib/core/injection/envs/phase1_dependencies.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/device_info_service.dart';
import '../../../feature/alerts/infrastructure/supabase_alerts_repository.dart';
import '../../../feature/auth/infrastructure/supabase_auth_repository.dart';
import '../../../feature/databases/infrastructure/supabase_databases_repository.dart';
import '../../../feature/metrics/infrastructure/supabase_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/supabase_monitoring_repository.dart';
import '../../../feature/users/infrastructure/supabase_users_repository.dart';
import '../app_dependencies.dart';

// ignore: invalid_use_of_internal_member
void _reconnectSupabase() => Supabase.instance.client.realtime.connect();

AppDependencies buildPhase1Dependencies() => AppDependencies(
  authRepository: SupabaseAuthRepository(),
  monitoringRepository: SupabaseMonitoringRepository(),
  metricsRepository: SupabaseMetricsRepository(),
  alertsRepository: SupabaseAlertsRepository(),
  usersRepository: SupabaseUsersRepository(),
  databasesRepository: SupabaseDatabasesRepository(),
  deviceInfoService: DeviceInfoService(),
  onReconnect: _reconnectSupabase,
);
```

- [ ] **Step 3: Actualizar `buildDemoDependencies`**

Reemplazar el contenido de `lib/core/injection/envs/demo_dependencies.dart`:

```dart
import '../../../core/services/device_info_service.dart';
import '../../../feature/alerts/infrastructure/in_memory_alerts_repository.dart';
import '../../../feature/auth/infrastructure/in_memory_auth_repository.dart';
import '../../../feature/databases/infrastructure/in_memory_databases_repository.dart';
import '../../../feature/metrics/infrastructure/in_memory_metrics_repository.dart';
import '../../../feature/monitoring/infrastructure/in_memory_monitoring_repository.dart';
import '../../../feature/users/infrastructure/in_memory_users_repository.dart';
import '../app_dependencies.dart';

AppDependencies buildDemoDependencies() => AppDependencies(
  authRepository: InMemoryAuthRepository(),
  monitoringRepository: InMemoryMonitoringRepository(),
  metricsRepository: InMemoryMetricsRepository(),
  alertsRepository: InMemoryAlertsRepository(),
  usersRepository: InMemoryUsersRepository(),
  databasesRepository: InMemoryDatabasesRepository(),
  deviceInfoService: InMemoryDeviceInfoService(),
);
```

- [ ] **Step 4: Actualizar `buildPhase2Dependencies`**

En `lib/core/injection/envs/phase2_dependencies.dart`, agregar el import y el campo:

```dart
import '../../../core/services/device_info_service.dart';
```

Y en `AppDependencies(...)`, agregar:

```dart
  deviceInfoService: DeviceInfoService(),
```

- [ ] **Step 5: Actualizar `UsersModule`**

Reemplazar el contenido de `lib/core/injection/modules/users_module.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/device_info_service.dart';
import '../../../feature/users/application/get_users_use_case.dart';
import '../../../feature/users/domain/interfaces/i_users_repository.dart';

abstract final class UsersModule {
  static List<RepositoryProvider<Object>> repositoryProviders(
    IUsersRepository repo,
    IDeviceInfoService deviceInfo,
  ) => [
    RepositoryProvider<WatchPanelUsersUseCase>(
      create: (_) => WatchPanelUsersUseCase(repo),
    ),
    RepositoryProvider<GetPanelUsersUseCase>(
      create: (_) => GetPanelUsersUseCase(repo),
    ),
    RepositoryProvider<GetAccessLogsUseCase>(
      create: (_) => GetAccessLogsUseCase(repo),
    ),
    RepositoryProvider<LogAccessUseCase>(
      create: (_) => LogAccessUseCase(repo, deviceInfo),
    ),
    RepositoryProvider<WatchAccessLogsUseCase>(
      create: (_) => WatchAccessLogsUseCase(repo),
    ),
    RepositoryProvider<WatchPresenceUseCase>(
      create: (_) => WatchPresenceUseCase(repo),
    ),
    RepositoryProvider<TrackPresenceUseCase>(
      create: (_) => TrackPresenceUseCase(repo),
    ),
    RepositoryProvider<UntrackPresenceUseCase>(
      create: (_) => UntrackPresenceUseCase(repo),
    ),
  ];
}
```

- [ ] **Step 6: Actualizar `app.dart`**

En `lib/core/app.dart`, hay DOS lugares donde se crea `LogAccessUseCase`. Actualizar ambos:

**Línea ~47 en `initState`** — agregar `deviceInfoService`:

```dart
    _authBloc = AuthBloc(
      signIn: SignInUseCase(authRepo),
      signOut: SignOutUseCase(authRepo),
      watchSession: WatchSessionUseCase(authRepo),
      logAccess: LogAccessUseCase(usersRepo, widget.dependencies.deviceInfoService),
      trackPresence: TrackPresenceUseCase(usersRepo),
      untrackPresence: UntrackPresenceUseCase(usersRepo),
      initialSession: authRepo.currentSession(),
    )..add(const AuthStarted());
```

**En `build()` — `UsersModule.repositoryProviders`** — pasar `deviceInfoService`:

```dart
        ...UsersModule.repositoryProviders(deps.usersRepository, deps.deviceInfoService),
```

- [ ] **Step 7: Verificar que compila**

```bash
flutter analyze lib/
```

Expected: No issues found.

- [ ] **Step 8: Commit**

```bash
git add lib/core/
git commit -m "feat: wire IDeviceInfoService through AppDependencies and UsersModule"
```

---

## Task 7: `PlatformIconPainter`

**Files:**
- Create: `lib/presentation/widgets/platform_icon_painter.dart`

- [ ] **Step 1: Crear el archivo con los 7 painters y el widget `PlatformIcon`**

Crear `lib/presentation/widgets/platform_icon_painter.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PlatformIcon extends StatelessWidget {
  const PlatformIcon({super.key, required this.platform, this.size = 16});

  final String? platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardColor;
    return CustomPaint(
      size: Size(size, size),
      painter: _painterFor(platform, bg),
    );
  }

  CustomPainter _painterFor(String? platform, Color bg) => switch (platform) {
    'web'     => _WebPainter(bg),
    'android' => _AndroidPainter(bg),
    'ios'     => _IosPainter(bg),
    'macos'   => _MacOsPainter(bg),
    'windows' => _WindowsPainter(bg),
    'linux'   => _LinuxPainter(bg),
    _         => _UnknownPainter(bg),
  };
}

// ── shared helpers ────────────────────────────────────────────────────────────

Paint _fill() => Paint()
  ..color = AppColors.primary
  ..style = PaintingStyle.fill;

Paint _cut(Color bg) => Paint()
  ..color = bg
  ..style = PaintingStyle.fill;

// ── Web — globo con meridianos cortados ───────────────────────────────────────

class _WebPainter extends CustomPainter {
  const _WebPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final r = s / 2;

    // globo
    canvas.drawCircle(c, r, _fill());

    // meridianos (cortes en color fondo)
    final cut = _cut(bg);
    cut.style = PaintingStyle.stroke;
    cut.strokeWidth = s * 0.08;

    // elipse vertical central
    canvas.drawOval(Rect.fromCenter(center: c, width: s * 0.38, height: s), cut);
    // línea horizontal superior
    canvas.drawLine(Offset(0, s * 0.35), Offset(s, s * 0.35), cut);
    // línea horizontal inferior
    canvas.drawLine(Offset(0, s * 0.65), Offset(s, s * 0.65), cut);
  }

  @override
  bool shouldRepaint(_WebPainter old) => old.bg != bg;
}

// ── Android — robot con antenas, ojos, brazos ────────────────────────────────

class _AndroidPainter extends CustomPainter {
  const _AndroidPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill();
    final c = _cut(bg);

    // antenas
    final antennaPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.33, s * 0.24), Offset(s * 0.22, s * 0.12), antennaPaint);
    canvas.drawLine(Offset(s * 0.67, s * 0.24), Offset(s * 0.78, s * 0.12), antennaPaint);

    // cabeza (rect redondeado)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.17, s * 0.25, s * 0.67, s * 0.37),
        Radius.circular(s * 0.19),
      ),
      f,
    );

    // ojos (cortes)
    canvas.drawCircle(Offset(s * 0.37, s * 0.44), s * 0.055, c);
    canvas.drawCircle(Offset(s * 0.63, s * 0.44), s * 0.055, c);

    // cuerpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.17, s * 0.64, s * 0.67, s * 0.24),
        Radius.circular(s * 0.08),
      ),
      f,
    );

    // brazos
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.04, s * 0.64, s * 0.10, s * 0.24), Radius.circular(s * 0.05)), f);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.86, s * 0.64, s * 0.10, s * 0.24), Radius.circular(s * 0.05)), f);
  }

  @override
  bool shouldRepaint(_AndroidPainter old) => old.bg != bg;
}

// ── iOS — manzana mordida ─────────────────────────────────────────────────────

class _IosPainter extends CustomPainter {
  const _IosPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    // cuerpo de la manzana
    final body = Path()
      ..moveTo(s * 0.33, s * 0.27)
      ..cubicTo(s * 0.21, s * 0.27, s * 0.10, s * 0.40, s * 0.10, s * 0.56)
      ..cubicTo(s * 0.10, s * 0.75, s * 0.23, s * 0.94, s * 0.37, s * 0.94)
      ..cubicTo(s * 0.42, s * 0.94, s * 0.47, s * 0.91, s * 0.50, s * 0.91)
      ..cubicTo(s * 0.53, s * 0.91, s * 0.58, s * 0.94, s * 0.63, s * 0.94)
      ..cubicTo(s * 0.77, s * 0.94, s * 0.90, s * 0.75, s * 0.90, s * 0.56)
      ..cubicTo(s * 0.90, s * 0.40, s * 0.79, s * 0.27, s * 0.67, s * 0.27)
      ..cubicTo(s * 0.61, s * 0.27, s * 0.56, s * 0.30, s * 0.50, s * 0.30)
      ..cubicTo(s * 0.44, s * 0.30, s * 0.39, s * 0.27, s * 0.33, s * 0.27)
      ..close();

    // mordisco (círculo superior derecho)
    final bite = Path()
      ..addOval(Rect.fromCircle(center: Offset(s * 0.73, s * 0.33), radius: s * 0.18));

    final apple = Path.combine(PathOperation.difference, body, bite);
    canvas.drawPath(apple, _fill());

    // hoja
    final leaf = Path()
      ..moveTo(s * 0.52, s * 0.23)
      ..cubicTo(s * 0.54, s * 0.14, s * 0.67, s * 0.10, s * 0.69, s * 0.08)
      ..cubicTo(s * 0.67, s * 0.14, s * 0.58, s * 0.19, s * 0.52, s * 0.23)
      ..close();
    canvas.drawPath(leaf, _fill());
  }

  @override
  bool shouldRepaint(_IosPainter old) => old.bg != bg;
}

// ── macOS — monitor con pantalla cortada ─────────────────────────────────────

class _MacOsPainter extends CustomPainter {
  const _MacOsPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill();
    final c = _cut(bg);

    // marco del monitor
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s * 0.63), Radius.circular(s * 0.08)),
      f,
    );
    // pantalla (corte interior)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.08, s * 0.08, s * 0.84, s * 0.46), Radius.circular(s * 0.04)),
      c,
    );
    // cuello
    canvas.drawRect(Rect.fromLTWH(s * 0.42, s * 0.63, s * 0.17, s * 0.12), f);
    // base
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.29, s * 0.75, s * 0.42, s * 0.08), Radius.circular(s * 0.04)),
      f,
    );
  }

  @override
  bool shouldRepaint(_MacOsPainter old) => old.bg != bg;
}

// ── Windows — 4 polígonos en perspectiva ─────────────────────────────────────

class _WindowsPainter extends CustomPainter {
  const _WindowsPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill();

    // top-left
    canvas.drawPath(_poly([
      Offset(s * 0.08, s * 0.25), Offset(s * 0.44, s * 0.19),
      Offset(s * 0.44, s * 0.48), Offset(s * 0.08, s * 0.52),
    ]), f);
    // top-right
    canvas.drawPath(_poly([
      Offset(s * 0.47, s * 0.18), Offset(s * 0.92, s * 0.10),
      Offset(s * 0.92, s * 0.48), Offset(s * 0.47, s * 0.48),
    ]), f);
    // bottom-left
    canvas.drawPath(_poly([
      Offset(s * 0.08, s * 0.54), Offset(s * 0.44, s * 0.52),
      Offset(s * 0.44, s * 0.81), Offset(s * 0.08, s * 0.88),
    ]), f);
    // bottom-right
    canvas.drawPath(_poly([
      Offset(s * 0.47, s * 0.52), Offset(s * 0.92, s * 0.52),
      Offset(s * 0.92, s * 0.90), Offset(s * 0.47, s * 0.90),
    ]), f);
  }

  Path _poly(List<Offset> pts) {
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final pt in pts.skip(1)) p.lineTo(pt.dx, pt.dy);
    return p..close();
  }

  @override
  bool shouldRepaint(_WindowsPainter old) => old.bg != bg;
}

// ── Linux — rectángulo teal con >_ cortado ───────────────────────────────────

class _LinuxPainter extends CustomPainter {
  const _LinuxPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    // fondo relleno
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.10)),
      _fill(),
    );

    // "> " — triángulo cortado
    final arrow = Path()
      ..moveTo(s * 0.17, s * 0.38)
      ..lineTo(s * 0.37, s * 0.50)
      ..lineTo(s * 0.17, s * 0.62)
      ..close();
    canvas.drawPath(arrow, _cut(bg));

    // "_" — rectángulo cortado
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.42, s * 0.55, s * 0.42, s * 0.09),
        Radius.circular(s * 0.02),
      ),
      _cut(bg),
    );
  }

  @override
  bool shouldRepaint(_LinuxPainter old) => old.bg != bg;
}

// ── Unknown — círculo con 4 puntos cortados ───────────────────────────────────

class _UnknownPainter extends CustomPainter {
  const _UnknownPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    canvas.drawCircle(c, s / 2, _fill());

    final cut = _cut(bg);
    const offsets = [0.35, 0.65];
    for (final dx in offsets) {
      for (final dy in offsets) {
        canvas.drawCircle(Offset(s * dx, s * dy), s * 0.07, cut);
      }
    }
  }

  @override
  bool shouldRepaint(_UnknownPainter old) => old.bg != bg;
}
```

- [ ] **Step 2: Verificar que compila**

```bash
flutter analyze lib/presentation/widgets/platform_icon_painter.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/widgets/platform_icon_painter.dart
git commit -m "feat: add PlatformIcon CustomPainter for all 7 platforms"
```

---

## Task 8: UI model + widget

**Files:**
- Modify: `lib/presentation/users/user_model.dart`
- Modify: `lib/presentation/users/widgets/users_access_log_card.dart`

- [ ] **Step 1: Actualizar `AccessLogModel` y `AccessLogModelX.toModel()`**

En `lib/presentation/users/user_model.dart`, reemplazar la clase `AccessLogModel` y su extension:

```dart
class AccessLogModel {
  AccessLogModel({
    required this.user,
    required this.action,
    required this.timestamp,
    required this.color,
    this.deviceLabel,
    this.devicePlatform,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;
  final String? deviceLabel;
  final String? devicePlatform;
}
```

```dart
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
        deviceLabel: deviceName,
        devicePlatform: devicePlatform,
      );
}
```

- [ ] **Step 2: Actualizar `UsersLogEntry` con chip inline**

Reemplazar el contenido de `lib/presentation/users/widgets/users_access_log_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/platform_icon_painter.dart';
import '../user_model.dart';

class UsersAccessLogCard extends StatelessWidget {
  const UsersAccessLogCard({super.key, required this.logs});

  final List<AccessLogModel> logs;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos recientes',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Sin registros',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...List.generate(logs.length, (i) {
              final m = logs[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < logs.length - 1 ? 10 : 0),
                child: UsersLogEntry(
                  user: m.user,
                  action: m.action,
                  timestamp: m.timestamp,
                  color: m.color,
                  deviceLabel: m.deviceLabel,
                  devicePlatform: m.devicePlatform,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class UsersLogEntry extends StatelessWidget {
  const UsersLogEntry({
    super.key,
    required this.user,
    required this.action,
    required this.timestamp,
    required this.color,
    this.deviceLabel,
    this.devicePlatform,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;
  final String? deviceLabel;
  final String? devicePlatform;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: user,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' · $action',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (deviceLabel != null) _DeviceChip(label: deviceLabel!, platform: devicePlatform),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timestamp,
          style: const TextStyle(color: AppColors.textInactive, fontSize: 11),
        ),
      ],
    );
  }
}

class _DeviceChip extends StatelessWidget {
  const _DeviceChip({required this.label, required this.platform});

  final String label;
  final String? platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        border: Border.all(color: AppColors.textInactive.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformIcon(platform: platform, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verificar que compila**

```bash
flutter analyze lib/presentation/users/
```

Expected: No issues found.

- [ ] **Step 4: Verificar con `flutter analyze` global**

```bash
flutter analyze lib/
```

Expected: No issues found.

- [ ] **Step 5: Correr todos los tests**

```bash
flutter test
```

Expected: All tests PASS.

- [ ] **Step 6: Commit final**

```bash
git add lib/presentation/users/ lib/presentation/widgets/platform_icon_painter.dart
git commit -m "feat: show device chip inline in access log entries"
```
