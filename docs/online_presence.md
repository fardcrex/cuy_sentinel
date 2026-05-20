# Online Presence — Conceptos e implementación

Panel Cuy Sentinel · referencia de estudio

---

## ¿Qué es TTL?

**TTL = Time To Live.** Es un número que le dice a un sistema: _"este dato existe durante X tiempo; después bórralo solo"_.

```
Redis: SET usuario:abc:online "1" EX 90
              ───────────────  ─  ──
              clave            valor  TTL en segundos
```

Después de 90 s, Redis elimina la clave automáticamente sin que nadie lo pida.
No hay un job de limpieza, no hay un cron, no hay una query de `DELETE WHERE expires_at < now()`. El TTL es **atómico y nativo** al sistema de almacenamiento.

### TTL aparece en muchos lugares

| Contexto | Cómo se llama | Ejemplo |
|---|---|---|
| Redis | `EX` / `PX` / `EXPIREAT` | `SET key val EX 90` |
| HTTP caché | `Cache-Control: max-age` | `max-age=3600` |
| DNS | TTL del registro A/CNAME | `300` segundos |
| JWT tokens | claim `exp` | `exp: 1700000000` |
| Cookies | `Max-Age` / `Expires` | `Max-Age=86400` |

La idea siempre es la misma: _autodestucción programada_ en lugar de limpieza manual.

---

## El problema de "¿quién está online?"

Un usuario está online si **su conexión está activa ahora mismo**. El problema es que en HTTP no hay conexión permanente — cada request es independiente. Hay tres soluciones de industria:

---

## Solución 1 — DB heartbeat (sin infra extra)

```
Cliente → UPDATE users
          SET session_expires_at = now() + INTERVAL '90 seconds'
          cada 30 segundos
```

El servidor nunca sabe si el cliente murió. Solo sabe cuándo fue el último pulso.
La UI calcula `isOnline = session_expires_at > now()`.

```dart
// PanelUser.isOnline — versión heartbeat
bool get isOnline {
  if (sessionExpiresAt == null) return false;
  return sessionExpiresAt!.isAfter(DateTime.now());
}
```

**Ventajas:**
- Funciona con cualquier base de datos
- Sin infra adicional
- Fácil de entender y debuggear

**Desventajas:**
- Escribe a la DB cada 30 s por usuario activo
- Latencia de detección = ventana de TTL (hasta 90 s)
- Requiere un `Timer.periodic` en el cliente
- La UI necesita otro `Timer.periodic` para re-evaluar `isOnline` localmente

**Ratio mínimo recomendado:** `TTL ≥ 2× heartbeat_interval` para tolerar un heartbeat perdido sin falso negativo. **Ideal: 3×** (30 s heartbeat → 90 s TTL).

| | Muy ajustado ❌ | Recomendado ✓ |
|---|---|---|
| Heartbeat | 45 s | 30 s |
| TTL | 60 s | 90 s |
| Ratio | 1.33× | **3×** |

---

## Solución 2 — Redis con TTL (mid-scale)

```
Cliente → SET user:{id}:online "1" EX 90   (cada 30 s)
Servidor → EXISTS user:{id}:online           (para saber si está online)
```

Redis expira la clave automáticamente si el cliente para de enviar pulsos.

**Ventajas:**
- No toca la DB principal
- O(1) para leer/escribir
- Escala a millones de usuarios
- TTL nativo — cero limpieza manual

**Desventajas:**
- Requiere Redis como infra adicional
- Sigue dependiendo de heartbeat periódico del cliente

**Lo usan:** Discord, Slack, WhatsApp Web para sus indicadores de presencia.

---

## Solución 3 — WebSocket Presence (tiempo real real)

El servidor detecta desconexiones **inmediatamente** porque el socket se cierra.
No hay ventana de 90 s. No hay timers en el cliente. No hay writes a la DB.

```
Cliente A se conecta  →  servidor registra "A está online"
Cliente A cierra app  →  TCP FIN llega al servidor → "A está offline" — INMEDIATO
```

### Supabase Presence (Phoenix Presence)

Supabase Realtime está construido sobre **Phoenix Channels** de Elixir, que implementa **Phoenix Presence** — un algoritmo distribuido de CRDT para tracking de presencia.

Cada cliente que se conecta al canal comparte su presencia con todos los demás.
Cuando la conexión WebSocket cae (app cerrada, pérdida de red), el servidor elimina esa presencia automáticamente.

```dart
// Unirse al canal y anunciar presencia
final channel = supabase.channel('panel:presence');
channel.onPresenceSync((_) {
  final onlineIds = channel.presenceState()
      .expand((s) => s.presences)
      .map((p) => p.payload['user_id'] as String)
      .toSet();
  // onlineIds se actualiza en tiempo real
});
channel.subscribe();
await channel.track({'user_id': userId});

// Salir
await channel.untrack();
```

**Ventajas:**
- Detección inmediata de desconexión
- Cero writes a la DB para presencia
- Sin `Timer.periodic` en el cliente
- Usa el WebSocket ya abierto para Realtime (sin coste extra de conexión)
- Escala horizontalmente con Phoenix clustering

**Desventajas:**
- Requiere WebSocket persistente (no aplica a algunos contextos mobile)
- La presencia es efímera: si el servidor se reinicia, se reconstruye desde las conexiones activas

---

## Comparación

| | DB Heartbeat | Redis TTL | WebSocket Presence |
|---|---|---|---|
| Infra extra | Ninguna | Redis | WebSocket (ya incluido en Supabase) |
| Latencia detección | ~90 s | ~90 s | < 1 s |
| Writes a DB por usuario | 2/min | 2/min Redis | **0** |
| Timer en cliente | Sí | Sí | **No** |
| Timer en UI | Sí | Sí | **No** |
| Escala | Baja | Alta | Alta |

---

## Implementación en Cuy Sentinel

### Lo que teníamos (heartbeat)

```
AuthBloc login → updateSession(session_expires_at = now + 90s)
               → Timer.periodic(30s) → heartbeat() → UPDATE session_expires_at
UsersBloc      → Timer.periodic(30s) → re-emitir estado para re-evaluar isOnline
```

4 lugares con lógica de presencia. Latencia de 90 s para detectar offline.

### Lo que tenemos ahora (Supabase Presence)

```
AuthBloc login  → trackPresence(userId)  → channel.track({'user_id': userId})
AuthBloc logout → untrackPresence()      → channel.untrack()
UsersBloc       → watchPresence()        → stream de Set<String> onlineIds
```

Cero timers. Detección inmediata. `UsersLoaded.onlineIds` es la fuente de verdad.

### Flujo de datos

```
Usuario abre app
  └─ AuthBloc._onStarted()
       └─ trackPresence(userId)
            └─ channel.track({'user_id': 'abc'})
                 └─ Supabase broadcast a todos en 'panel:presence'
                      └─ onPresenceSync dispara
                           └─ _presenceCtrl.add(onlineIds)
                                └─ UsersBloc recibe Set{'abc', ...}
                                     └─ UsersLoaded(onlineIds: {...})
                                          └─ UI actualiza badge online
```

```
Usuario cierra app (sin logout)
  └─ TCP cierra el socket WebSocket
       └─ Supabase detecta la desconexión
            └─ elimina la presencia de 'abc' del canal
                 └─ onPresenceSync dispara en todos los clientes conectados
                      └─ onlineIds ya no contiene 'abc'
                           └─ UI actualiza badge a offline — INMEDIATO
```

### Archivos modificados

| Archivo | Cambio |
|---|---|
| `i_users_repository.dart` | `+watchPresence` `+trackPresence` `+untrackPresence` `-heartbeat` |
| `supabase_users_repository.dart` | Implementación con `RealtimeChannel` |
| `in_memory_users_repository.dart` | `watchPresence` usa `sessionExpiresAt` de los datos demo |
| `get_users_use_case.dart` | `+WatchPresenceUseCase` `+TrackPresenceUseCase` `+UntrackPresenceUseCase` `-SendHeartbeatUseCase` |
| `users_module.dart` | Registro de los nuevos use cases |
| `users_state.dart` | `UsersLoaded` ahora tiene `onlineIds: Set<String>` |
| `users_bloc.dart` | `_watchAll()` combina 3 streams: users + logs + presence |
| `user_model.dart` | `toModel` recibe `isOnline` explícito en vez de leerlo del dominio |
| `users_content_view.dart` | Pasa `state.isOnline(user.id)` al model |
| `auth_bloc.dart` | Reemplaza heartbeat timer por `track`/`untrack` |
| `app.dart` | Constructor de `AuthBloc` sin heartbeat |

---

## Notas para Fase 2 (Node.js + Socket.IO)

Socket.IO tiene presencia nativa similar:

```js
// Server
io.on('connection', (socket) => {
  const userId = socket.handshake.auth.userId;
  onlineUsers.add(userId);
  io.emit('presence:update', [...onlineUsers]);

  socket.on('disconnect', () => {
    onlineUsers.delete(userId);
    io.emit('presence:update', [...onlineUsers]);
  });
});
```

El `NodeUsersRepository.watchPresence()` recibirá este stream vía Socket.IO en lugar del canal de Supabase. La interfaz `IUsersRepository` no cambia.
