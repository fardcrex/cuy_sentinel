# Múltiples clientes Supabase — mismo proyecto, ciclos de vida independientes

## El problema

`Supabase.instance.client` es un singleton. Cuando el usuario cierra sesión, el
logout limpio cierra todos sus canales y desconecta el WebSocket:

```dart
await _client.realtime.removeAllChannels(); // mata todos los canales
_client.realtime.disconnect();              // cierra el TCP
await _client.auth.signOut();
```

Si existiera un canal que debe **sobrevivir al logout** — notificaciones globales,
telemetría, monitoreo de infraestructura independiente del usuario — este canal
moriría también, porque comparte el mismo WebSocket.

---

## La solución: segunda instancia con las mismas credenciales

`SupabaseClient` no es un singleton obligatorio. Se puede instanciar manualmente
con el mismo `url` y `anonKey` del proyecto:

```dart
// lib/core/services/push_realtime_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class PushRealtimeService {
  PushRealtimeService({required String url, required String anonKey})
      : _client = SupabaseClient(url, anonKey);

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  void start() {
    _channel = _client.channel('push:global');
    _channel!
        .onBroadcast(
          event: 'alert',
          callback: (payload) => _onGlobalAlert(payload),
        )
        .subscribe();
  }

  void _onGlobalAlert(Map<String, dynamic> payload) {
    // mostrar notificación aunque el usuario no esté logueado
  }

  Future<void> dispose() async {
    await _client.realtime.removeAllChannels();
    _client.realtime.disconnect();
  }
}
```

```
Supabase.instance.client  (singleton — sesión del usuario)
│  WebSocket A
├── alert_events        ← muere con logout ✓
├── metrics             ← muere con logout ✓
└── panel:presence      ← muere con logout ✓

PushRealtimeService._client  (instancia manual)
│  WebSocket B
└── push:global         ← sobrevive al logout ✓
```

Mismo proyecto Supabase, dos conexiones TCP, ciclos de vida completamente
independientes.

---

## Credenciales: ¿cuándo usar las mismas y cuándo distintas?

| Caso | Key a usar |
|---|---|
| Canal de notificaciones globales (frontend) | `anonKey` — RLS controla el acceso |
| Canal de telemetría sin restricciones | `service_role` ← **nunca en Flutter** |
| Panel de usuario autenticado | `anonKey` + JWT del usuario |

El `service_role` bypasea RLS y da acceso total a la base de datos. Solo va en
el backend (colector Go, funciones Edge). **Nunca se incluye en el bundle de Flutter.**

---

## Cuándo aplica este patrón en Cuy Sentinel

Actualmente **no aplica** — todos los canales son de sesión y deben morir con
el logout. El `removeAllChannels()` + `disconnect()` en `SupabaseAuthRepository`
es correcto.

Aplicaría en Fase 2 si se agrega:

- **Notificaciones push fallback**: alertas críticas que deben llegar aunque el
  usuario esté en la pantalla de login o haya cerrado sesión temporalmente.
- **Canal de broadcast de mantenimiento**: el equipo de ops puede enviar mensajes
  a todos los clientes conectados sin importar si están autenticados.
- **Telemetría del cliente**: métricas de uso del panel (latencia de navegación,
  errores de UI) que no dependen de la sesión del usuario.

---

## Ciclo de vida del segundo cliente

Si se implementa, debe vivir al nivel de la app — no dentro de un repositorio
que se recrea con cada login:

```dart
// lib/main_phase1.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // segundo cliente — vive toda la vida de la app
  final pushService = PushRealtimeService(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  )..start();

  runApp(CuySentinelApp(
    dependencies: buildPhase1Dependencies(),
    pushService: pushService,
  ));
}
```

Y en el `dispose` de la app (raramente invocado en móvil, más relevante en desktop/web):

```dart
@override
void dispose() {
  pushService.dispose();
  super.dispose();
}
```
