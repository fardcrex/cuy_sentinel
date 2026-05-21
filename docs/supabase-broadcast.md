# Supabase Broadcast — WebSocket efímero en Flutter

## Qué es

Broadcast es el canal de mensajería efímera de Supabase Realtime. Los mensajes se
entregan a todos los suscriptores conectados en ese momento y **no se persisten** —
no hay tabla, no hay historial, no hay WAL. Si un cliente no está conectado cuando
se envía el mensaje, no lo recibe nunca.

Es el equivalente exacto de `socket.emit` / `socket.on` de Socket.IO, pero sobre
el WebSocket de Supabase que ya está abierto para Presence y Postgres Changes.

---

## Arquitectura interna

```
Cliente A                    Servidor Supabase (Phoenix)         Cliente B
    |                               |                                |
    |── subscribe('room:chat') ────>|<── subscribe('room:chat') ────|
    |                               |                                |
    |── broadcast(event:'msg') ────>|──── forward a todos ─────────>|
    |                               |                                |
    |                        [no se guarda]
```

Un canal de Broadcast es identificado por su nombre (`room:chat`, `panel:ops`, etc.).
El servidor actúa solo como router — recibe el mensaje de un cliente y lo reenvía a
todos los demás suscritos al mismo canal. No hay base de datos involucrada.

---

## API en Flutter

### 1. Crear y suscribir el canal

```dart
final channel = Supabase.instance.client.channel('room:chat');

channel.subscribe((status, error) {
  // RealtimeSubscribeStatus.subscribed → listo para enviar y recibir
  // RealtimeSubscribeStatus.channelError → reconectar
  // RealtimeSubscribeStatus.timedOut → reconectar
});
```

`channel()` es lazy — solo crea el objeto local. La suscripción real al servidor
ocurre en `subscribe()`.

### 2. Escuchar mensajes entrantes

```dart
channel.onBroadcast(
  event: 'chat_message',          // filtra por tipo de evento
  callback: (Map<String, dynamic> payload) {
    final text = payload['text'] as String;
    final from = payload['from'] as String;
    // actualizar UI
  },
);
```

`onBroadcast` debe llamarse **antes** de `subscribe()`. Si se llama después, los
mensajes que lleguen antes de que el listener esté registrado se pierden.

El orden correcto es siempre:

```dart
channel
  .onBroadcast(event: 'msg', callback: _onMessage)  // 1. registrar listeners
  .subscribe();                                       // 2. suscribir
```

### 3. Enviar un mensaje

```dart
await channel.sendBroadcastMessage(
  event: 'chat_message',
  payload: {
    'from': 'Jair',
    'text': 'hola',
    'at': DateTime.now().toUtc().toIso8601String(),
  },
);
```

`sendBroadcastMessage` es async pero no hay confirmación de entrega — es
fire-and-forget. Si el servidor no recibe el mensaje (WebSocket caído), el Future
completa sin error pero el mensaje no llegó a nadie.

### 4. Desuscribir y limpiar

```dart
await Supabase.instance.client.removeChannel(channel);
```

Esto envía `phx_leave` al servidor, cierra el canal lógico y libera la referencia.
El WebSocket TCP subyacente permanece abierto para otros canales.

---

## Comportamiento del payload

El payload es un `Map<String, dynamic>` libre — cualquier estructura JSON serializable.
Supabase no valida ni tipea el contenido. El tamaño máximo por mensaje es **32 KB**
en el plan gratuito.

Lo que llega al `callback` es exactamente lo que se pasó en `payload`:

```dart
// envío
channel.sendBroadcastMessage(
  event: 'alert',
  payload: {'severity': 'critical', 'service': 'passbolt'},
);

// recepción (todos los demás)
channel.onBroadcast(
  event: 'alert',
  callback: (payload) {
    // payload == {'severity': 'critical', 'service': 'passbolt'}
  },
);
```

El emisor **no recibe su propio mensaje** por defecto. Para activarlo:

```dart
final channel = client.channel(
  'room:chat',
  opts: const RealtimeChannelConfig(self: true),  // recibe sus propios mensajes
);
```

---

## Múltiples eventos en un canal

Un solo canal puede manejar múltiples tipos de eventos. No hace falta un canal por
tipo de mensaje:

```dart
channel
  .onBroadcast(event: 'chat_message', callback: _onChat)
  .onBroadcast(event: 'typing', callback: _onTyping)
  .onBroadcast(event: 'alert', callback: _onAlert)
  .subscribe();
```

El servidor filtra por `event` antes de entregar al callback correcto.

---

## Combinación con Presence en el mismo canal

Broadcast y Presence pueden coexistir en el mismo canal. No necesitan canales
separados:

```dart
channel
  .onPresenceSync((_) => _updateOnlineList())
  .onBroadcast(event: 'chat_message', callback: _onMessage)
  .subscribe((status, _) async {
    if (status == RealtimeSubscribeStatus.subscribed) {
      await channel.track({'user_id': userId, 'display_name': name});
    }
  });
```

```
canal 'room:chat'
├── Presence  → quién está conectado ahora
└── Broadcast → mensajes de chat entre conectados
```

Esto es exactamente lo que haría un chat interno en Cuy Sentinel: Presence para
mostrar quién está online, Broadcast para los mensajes.

---

## Limitaciones importantes

| Limitante | Detalle |
|---|---|
| Sin persistencia | Si no estás conectado, no recibes el mensaje |
| Sin orden garantizado | Los mensajes pueden llegar desordenados bajo carga |
| Sin confirmación de entrega | `sendBroadcastMessage` es fire-and-forget |
| 32 KB por mensaje | Plan gratuito — suficiente para texto, no para imágenes |
| Sin historial | Para historial se necesita Postgres Changes + tabla |
| Rate limit | 100 mensajes/seg por canal en plan gratuito |

---

## Cuándo usar Broadcast vs Postgres Changes

| Caso | Broadcast | Postgres Changes |
|---|---|---|
| Chat en tiempo real (sin historial) | ✓ | |
| Notificaciones efímeras (typing, cursor) | ✓ | |
| Alertas que deben persistir | | ✓ |
| Chat con historial recuperable | | ✓ |
| Sincronización de estado entre tabs | ✓ | |
| Auditoría / logs | | ✓ |

Para Cuy Sentinel: las alertas de infraestructura usan Postgres Changes (se guardan
en `alert_events`). Un hipotético chat de operadores usaría Broadcast.

---

## Ejemplo completo — chat mínimo en Flutter

```dart
class ChatService {
  ChatService({required this.userId, required this.displayName});

  final String userId;
  final String displayName;

  late final RealtimeChannel _channel;
  final _messages = StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get messages => _messages.stream;

  void start() {
    _channel = Supabase.instance.client.channel('ops:chat');
    _channel
        .onBroadcast(
          event: 'msg',
          callback: (payload) => _messages.add(ChatMessage.fromJson(payload)),
        )
        .subscribe();
  }

  Future<void> send(String text) => _channel.sendBroadcastMessage(
        event: 'msg',
        payload: {
          'from': displayName,
          'user_id': userId,
          'text': text,
          'at': DateTime.now().toUtc().toIso8601String(),
        },
      );

  Future<void> dispose() async {
    await Supabase.instance.client.removeChannel(_channel);
    await _messages.close();
  }
}
```
