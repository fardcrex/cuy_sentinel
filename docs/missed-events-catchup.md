# Catchup de eventos perdidos durante reconexión

## El problema

Supabase Realtime envía eventos INSERT/UPDATE/DELETE solo mientras el WebSocket
está activo. Si el cliente se desconecta (background, modo avión, red inestable),
los eventos que ocurrieron durante ese tiempo se pierden para siempre — el servidor
no los encola ni los reenvía al reconectar.

Esto afecta **directamente a las notificaciones**: si llegan 3 alertas críticas
mientras el usuario no tiene conexión, al volver al foreground no verá ninguna.

```
T=0   usuario pone modo avión
T=30  alerta CPU crítica disparada  → INSERT en alert_events  → PERDIDO
T=60  alerta disco warning          → INSERT en alert_events  → PERDIDO
T=90  usuario quita modo avión
T=92  WebSocket reconecta
T=92  canal alert_inserts suscrito  → solo escucha desde aquí en adelante
T=92  usuario no ve nada            ← ❌ problema
```

Comparación con notificaciones del sistema operativo: FCM/APNs tienen un servidor
de cola — el OS entrega las notificaciones acumuladas al reconectar. Supabase
Realtime no tiene ese servidor de cola.

---

## La solución: catchup query al reconectar

Al momento en que el canal se suscribe exitosamente, hacer una consulta REST que
busque alertas disparadas después del último evento recibido (`_lastSeenAt`).

```
T=92  canal suscrito → onSubscribed dispara → catchup query
      SELECT * FROM alert_events
      WHERE triggered_at > '...T=0...'   ← _lastSeenAt
        AND resolved = false
      ORDER BY triggered_at ASC

      → devuelve alerta T=30 y alerta T=60
      → se emiten como AlertNotifierNewAlert en orden cronológico
      → el usuario ve ambas notificaciones al volver
```

---

## Implementación

### `_lastSeenAt` — ancla temporal

```dart
// En AlertNotifierCubit
DateTime _lastSeenAt = DateTime.now();

void start() {
  _lastSeenAt = DateTime.now(); // ancla: "no me interesan alertas anteriores"
  _sub = _watchAlertInserts.execute(
    onSubscribed: _catchUpMissedAlerts,
  ).listen((alert) {
    _lastSeenAt = alert.triggeredAt; // avanza con cada INSERT recibido
    emit(AlertNotifierNewAlert(alert));
  });
}
```

`_lastSeenAt` responde a la pregunta: *"¿desde cuándo necesito buscar alertas?"*

- Al iniciar `start()` → `DateTime.now()` → no busca historial antiguo
- Al recibir un INSERT → avanza al `triggeredAt` del alert → el catchup siguiente
  solo busca desde ese punto

### `onSubscribed` — el gancho de reconexión

```dart
// En SupabaseAlertsRepository._buildAlertInsertsStream
.subscribe((status, _) {
  if (status == RealtimeSubscribeStatus.subscribed) {
    onSubscribed?.call(); // ← dispara en PRIMERA conexión y en CADA reconexión
  }
  ...
});
```

Por qué `subscribed` y no `onReconnected` de retryStream:

- `retryStream.onReconnected` solo dispara cuando el stream **emite datos** tras
  un retry — para INSERT events esto puede tardar horas si no hay alertas
- `subscribed` dispara inmediatamente al establecer el canal — exactamente cuando
  ya es seguro hacer el catchup (el canal ya escucha, no hay ventana ciega)

### `_catchUpMissedAlerts` — la consulta

```dart
Future<void> _catchUpMissedAlerts() async {
  final missed = await _getAlertsSince.execute(_lastSeenAt);
  for (final alert in missed) {
    if (isClosed) return;
    _lastSeenAt = alert.triggeredAt; // actualiza para evitar duplicados
    emit(AlertNotifierNewAlert(alert));
  }
}
```

Los alerts se emiten en orden cronológico (la query ordena por `triggered_at ASC`),
simulando que llegaron naturalmente uno tras otro.

### `getAlertsSince` — la query

```sql
-- Supabase / PostgreSQL
SELECT * FROM alert_events
WHERE triggered_at > $1    -- estrictamente después de _lastSeenAt
  AND resolved = false      -- solo activas
ORDER BY triggered_at ASC  -- más antiguas primero
```

---

## Casos de uso narrativos

### Caso 1 — Usuario pone modo avión y vuelve

**Contexto:** Daniel está revisando el panel en su laptop. Cierra la tapa para ir a
una reunión de 20 minutos. Durante ese tiempo el colector Go detecta dos problemas.

```
09:00  Daniel cierra la laptop
       → OS suspende la red
       → WebSocket Supabase se cierra (TCP drop)
       → retryStream detecta el error, espera con backoff
       → _lastSeenAt = 09:00 (último alert recibido antes de cerrar)

09:05  CPU de Passbolt llega a 92%
       → Go collector inserta alert_events (id: A1, triggered_at: 09:05)
       → nadie escucha el INSERT — Daniel está desconectado

09:18  Disco de ChkMonitor llega a 88%
       → Go collector inserta alert_events (id: A2, triggered_at: 09:18)
       → nadie escucha el INSERT

09:20  Daniel abre la laptop
       → OS restaura la red
       → app llama realtime.connect() (WidgetsBindingObserver)
       → retryStream reconecta, llama _buildAlertInsertsStream
       → canal 'alert_inserts' se suscribe
       → RealtimeSubscribeStatus.subscribed → onSubscribed dispara

09:20  _catchUpMissedAlerts() ejecuta:
       SELECT * FROM alert_events
       WHERE triggered_at > '09:00' AND resolved = false
       ORDER BY triggered_at ASC
       → encuentra A1 (09:05) y A2 (09:18)

09:20  emit(AlertNotifierNewAlert(A1))  → diálogo CPU crítica
09:20  emit(AlertNotifierNewAlert(A2))  → diálogo disco warning
       _lastSeenAt = 09:18

09:20  Daniel ve las dos notificaciones al abrir la laptop ✅
```

---

### Caso 2 — Red inestable durante guardia nocturna

**Contexto:** Jheampierre tiene el panel abierto en su PC de guardia. La red
del campus cae y vuelve varias veces durante la noche.

```
02:00  Red cae por primera vez
       → _lastSeenAt = 02:00

02:03  Alerta latencia SNMP (id: B1, triggered_at: 02:03) → INSERT
02:06  Red vuelve → canal suscrito → catchup desde 02:00
       → encuentra B1 → notificación ✅
       → _lastSeenAt = 02:03

02:30  Red vuelve a caer
       → _lastSeenAt = 02:03

02:35  Alerta RAM warning (id: B2, triggered_at: 02:35) → INSERT
02:38  Red vuelve → canal suscrito → catchup desde 02:03
       → encuentra B2 → notificación ✅
       → _lastSeenAt = 02:35

Resultado: ninguna alerta se perdió a pesar de 2 cortes de red ✅
```

---

### Caso 3 — Alerta disparada Y resuelta mientras el usuario estaba offline

**Contexto:** El colector detecta un pico de CPU, inserta una alerta, y 2 minutos
después la métrica baja y el propio colector la resuelve — todo mientras Jair
tenía el modo avión activado.

```
10:00  Jair activa modo avión → _lastSeenAt = 10:00

10:05  CPU sube a 91%
       → INSERT alert_events (id: C1, triggered_at: 10:05, resolved: false)

10:07  CPU baja a 45%
       → UPDATE alert_events SET resolved = true WHERE id = C1

10:10  Jair desactiva modo avión → canal suscrito → catchup

       SELECT * FROM alert_events
       WHERE triggered_at > '10:00' AND resolved = false
       → C1 ya tiene resolved = true → NO aparece en resultados

10:10  Jair no recibe notificación de C1 ✅
       (correcto — el problema ya se resolvió solo, notificar sería ruido)
```

---

### Caso 4 — Múltiples sesiones (mismo usuario en dos dispositivos)

**Contexto:** Jair tiene el panel abierto en Chrome y en su celular. El celular
se desconecta, Chrome sigue online y recibe las alertas normalmente.

```
Laptop (Chrome):   _lastSeenAt avanza con cada alerta → sin catchup pendiente
Celular (Flutter): _lastSeenAt = 11:00 (momento de desconexión)

11:05  Alerta (id: D1) → INSERT
       → Chrome recibe por realtime ✅
       → Celular: offline, pierde el INSERT

11:10  Celular reconecta → catchup desde 11:00
       → encuentra D1 → notificación ✅
       → _lastSeenAt = 11:05

Resultado: cada dispositivo maneja su propio _lastSeenAt de forma independiente ✅
No hay coordinación entre dispositivos — cada uno se cura solo ✅
```

---

### Caso 5 — Logout y login con otro usuario

**Contexto:** Jair termina su turno y Daniel inicia sesión en la misma máquina.

```
18:00  Jair hace logout
       → AuthBloc emite AuthUnauthenticated
       → AlertNotifierCubit.stop() → cancela suscripción
       → _lastSeenAt queda en el último valor de Jair (ej: 17:55)

18:05  Daniel hace login
       → AuthBloc emite AuthAuthenticated
       → AlertNotifierCubit.start()
       → _lastSeenAt = DateTime.now() = 18:05  ← RESET
       → canal suscrito → catchup desde 18:05
       → no aparecen las alertas del turno de Jair

Resultado: Daniel empieza desde cero, sin historial de otra sesión ✅
```

---

## Casos límite

### Primera conexión

`_lastSeenAt = DateTime.now()` justo antes de suscribir. Cuando `onSubscribed`
dispara (1-2s después), la query busca alertas en ese pequeño intervalo. En la
práctica no hay alertas en 1-2s → catchup vacío → sin notificaciones basura. ✅

### Alerta que llega mientras se está reconectando

```
T=0  conexión cae  →  _lastSeenAt = T_último_alert
T=30 nueva alerta  →  INSERT en DB
T=35 canal suscrito → onSubscribed
     catchup: SELECT WHERE triggered_at > T_último_alert
     → encuentra la alerta de T=30 ✅
T=40 otra alerta llega por realtime normal ✅
```

### Alerta resuelta antes de que hagas el catchup

```dart
// getAlertsSince filtra resolved = false
// si la alerta se resolvió mientras estabas offline, no aparece
// comportamiento correcto — ya no es relevante
```

### Logout → login

`stop()` cancela la suscripción. El siguiente `start()` reinicia
`_lastSeenAt = DateTime.now()` — el historial anterior no reaparece. ✅

### Duplicados

`getAlertsSince` usa `>` estricto (no `>=`). El último alert recibido por realtime
tiene su `triggeredAt` guardado en `_lastSeenAt`. La query excluye exactamente ese
instante. Sin duplicados. ✅

---

## Por qué esta solución y no otras

| Alternativa | Problema |
|---|---|
| Guardar eventos en local storage | Complejo, desfasado si otro cliente resolvió la alerta |
| Polling periódico | Consume batería, latencia artificial |
| Supabase Cola (BullMQ / pg_boss) | Over-engineering para este caso |
| Ignorar el problema | Usuario pierde alertas críticas |
| `retryStream.onReconnected` | Solo dispara al recibir datos — INSERT events son raros |

El catchup query es el balance correcto: simple, usa infraestructura existente
(Postgres/Supabase REST), y solo se ejecuta cuando realmente es necesario
(al reconectar, no periódicamente).
