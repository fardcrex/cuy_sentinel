# Estado de conexión Realtime — enfoque global vs contextual

Cuando usas streams en tiempo real (Supabase Realtime, WebSockets, etc.) y quieres
mostrar un banner de "reconectando" al usuario, hay dos enfoques principales.

---

## Enfoque A — Banner contextual (el que usamos)

Cada pantalla observa el estado de reconexión de su propio cubit.
No hay coordinación global.

```
MetricsPage  → MetricsCubit.isReconnecting → "⚠ Reconectando: métricas"
ServicesPage → ServicesCubit.isReconnecting → "⚠ Reconectando: servicios"
```

**Cuándo usarlo:**
- Cada pantalla consume streams independientes
- El usuario solo necesita saber si la pantalla que está viendo tiene problemas
- Quieres mínimo acoplamiento entre partes del sistema

---

## Enfoque B — Banner global con Map (el documentado aquí)

Un cubit central trackea el estado de todos los streams de la app.
Un único banner global muestra qué streams están caídos en este momento.

**Cuándo usarlo:**
- Tienes un dashboard que agrega datos de múltiples fuentes
- El usuario necesita visibilidad de toda la infraestructura, no solo su pantalla actual
- Ejemplo real: panel de monitoreo de infraestructura, sala de control, trading dashboard

---

## Implementación del enfoque B

### 1. `RealtimeStatusCubit`

```dart
// lib/core/realtime/realtime_status_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

class RealtimeStatusCubit extends Cubit<Map<String, bool>> {
  RealtimeStatusCubit() : super({});

  /// Llama esto cuando un stream entra en retry.
  /// [streamId] es un identificador legible: 'metrics', 'alerts', etc.
  void onRetrying(String streamId) {
    emit({...state, streamId: false});
  }

  /// Llama esto cuando el stream emitió su primer dato tras reconectar.
  void onReconnected(String streamId) {
    emit({...state, streamId: true});
  }

  /// true si al menos un stream está caído.
  bool get hasDisconnected => state.values.any((v) => !v);

  /// Lista de streams actualmente reconectando.
  List<String> get reconnecting =>
      state.entries.where((e) => !e.value).map((e) => e.key).toList();
}
```

### 2. `retryStream` con callbacks

```dart
// lib/core/utils/stream_retry.dart

Stream<T> retryStream<T>(
  Stream<T> Function() factory, {
  Duration initial = const Duration(seconds: 2),
  Duration max = const Duration(seconds: 30),
  void Function()? onRetrying,
  void Function()? onReconnected,
}) async* {
  var backoff = initial;
  var wasRetrying = false;

  while (true) {
    try {
      await for (final value in factory()) {
        if (wasRetrying) {
          wasRetrying = false;
          onReconnected?.call();
        }
        backoff = initial;
        yield value;
      }
    } catch (_) {
      wasRetrying = true;
      onRetrying?.call();
      await Future.delayed(backoff);
      backoff = backoff * 2 > max ? max : backoff * 2;
    }
  }
}
```

> **Nota:** `wasRetrying` evita llamar `onReconnected` en la primera emisión
> si nunca hubo error — solo notifica cuando se recupera de una caída real.

### 3. Repositorio conectado al cubit

```dart
// lib/feature/metrics/infrastructure/supabase_metrics_repository.dart

class SupabaseMetricsRepository implements IMetricsRepository {
  SupabaseMetricsRepository({required this.statusCubit});

  final RealtimeStatusCubit statusCubit;

  @override
  Stream<List<Metric>> watchLatest({required String serviceId}) =>
      retryStream(
        () => _client
            .from('metrics')
            .stream(primaryKey: ['id'])
            .eq('service_id', serviceId)
            .map((rows) => rows.map(Metric.fromJson).toList()),
        onRetrying: () => statusCubit.onRetrying('metrics'),
        onReconnected: () => statusCubit.onReconnected('metrics'),
      );
}
```

### 4. Banner global en `PanelShell`

```dart
// lib/presentation/widgets/panel_shell.dart

BlocBuilder<RealtimeStatusCubit, Map<String, bool>>(
  builder: (context, status) {
    final reconnecting = context.read<RealtimeStatusCubit>().reconnecting;
    return Column(
      children: [
        if (reconnecting.isNotEmpty)
          _ReconnectingBanner(streams: reconnecting),
        Expanded(child: child),
      ],
    );
  },
)

class _ReconnectingBanner extends StatelessWidget {
  const _ReconnectingBanner({required this.streams});
  final List<String> streams;

  @override
  Widget build(BuildContext context) {
    final label = streams.join(', ');
    return Container(
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '⚠ Reconectando: $label...',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
```

### 5. Registro en `AppDependencies`

```dart
class AppDependencies {
  const AppDependencies({
    required this.metricsRepository,
    required this.alertsRepository,
    // ... otros repos
    required this.realtimeStatus, // ← inyectado desde infraestructura
  });

  final RealtimeStatusCubit realtimeStatus;
  // ...
}

// En phase1_dependencies.dart:
final status = RealtimeStatusCubit();
AppDependencies(
  realtimeStatus: status,
  metricsRepository: SupabaseMetricsRepository(statusCubit: status),
  alertsRepository: SupabaseAlertsRepository(statusCubit: status),
);
```

---

## Sealed class para estado de retry + countdown en UI

### El problema con callbacks separados

```dart
// ❌ dos callbacks — convención implícita, no escala
retryStream(..., onRetrying: () {...}, onReconnected: () {...})

// ❌ nullable como señal — null significa "reconectado"? no es obvio
retryStream(..., onRetry: (Duration? backoff) {...})
```

### La solución: sealed class explícita

```dart
sealed class RetryState {}

class Retrying extends RetryState {
  Retrying(this.backoff);
  final Duration backoff; // cuánto esperará antes del próximo intento
}

class Reconnected extends RetryState {}
```

El sealed class garantiza exhaustividad en el switch — el compilador obliga a
manejar ambos casos. La `Duration` en `Retrying` permite mostrar un countdown
real en la UI.

```dart
// call site — legible y exhaustivo
onRetry: (state) => switch (state) {
  Retrying(:final backoff) => _startCountdown(backoff),
  Reconnected()            => _stopCountdown(),
},
```

### Countdown: responsabilidad de capas

El stream solo emite DOS eventos de estado:
- `Retrying(backoff: 8s)` → "empezó a reintentar, próximo intento en 8s"
- `Reconnected()` → "volvió a emitir datos"

El `Timer.periodic` vive en el **cubit**, no en el widget ni en el stream:

```dart
// En AlertsCubit
void _startCountdown(Duration backoff) {
  _isReconnecting = true;
  _secondsLeft = backoff.inSeconds;
  _countdownTimer?.cancel();
  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (_secondsLeft > 0) _secondsLeft--;
    _emitLoaded(); // re-emite estado con nuevo secondsLeft
  });
  _emitLoaded();
}

void _stopCountdown() {
  _isReconnecting = false;
  _secondsLeft = 0;
  _countdownTimer?.cancel();
  _countdownTimer = null;
  _emitLoaded();
}
```

El widget solo renderiza lo que el cubit dice:

```dart
// AlertsPage
if (isReconnecting)
  ReconnectingBanner(secondsLeft: reconnectingInSeconds)

// ReconnectingBanner
String get _label {
  final s = widget.secondsLeft;
  if (s != null && s > 0) return 'RECONECTANDO EN ${s}S';
  return 'RECONECTANDO';
}
```

### Por qué el Timer vive en el cubit y no en el widget

| | Timer en widget | Timer en cubit |
|---|---|---|
| Estado | Local, se pierde si el widget se reconstruye | Persistente en el cubit |
| Testeable | ❌ acoplado a Flutter | ✅ test unitario puro |
| Múltiples widgets | ❌ cada uno tiene su propio timer | ✅ un solo timer, N widgets |
| Responsabilidad | Presentación gestiona lógica | Lógica en capa correcta |

### Flujo completo

```
stream falla
  → retryStream: backoff = 2s
  → onRetry(Retrying(2s))
  → cubit._startCountdown(2s)
  → Timer.periodic(1s): emite 2, 1, 0...
  → banner: "RECONECTANDO EN 2S" → "1S" → "RECONECTANDO"

retryStream espera 2s → reintenta → stream vuelve a emitir
  → onRetry(Reconnected())
  → cubit._stopCountdown()
  → banner desaparece

próximo fallo (backoff duplica a 4s):
  → banner: "RECONECTANDO EN 4S" → "3S" → ... → "RECONECTANDO"
```

---

## Comparación final

| | Enfoque A (contextual) | Enfoque B (global) |
|---|---|---|
| Complejidad | Baja | Media |
| Acoplamiento | Ninguno entre pantallas | Repos dependen del cubit central |
| Visibilidad | Solo la pantalla actual | Toda la app |
| Casos de uso | Apps con vistas independientes | Dashboards, salas de control |
| Condición de carrera | Imposible | Resuelta con Map por stream |

---

## ¿Por qué el Map resuelve la condición de carrera?

Con un `bool` global:
```
stream A reconecta → isReconnecting = false  ← incorrecto, stream B sigue caído
```

Con un `Map<String, bool>`:
```
stream A reconecta → map['alerts'] = true   → map tiene 'metrics': false → banner sigue
stream B reconecta → map['metrics'] = true  → map vacío de false → banner desaparece
```

Cada stream escribe solo su propia entrada. No hay escrituras concurrentes sobre
el mismo campo — Dart es single-threaded, los callbacks de `retryStream` se
ejecutan en el mismo isolate, sin locks necesarios.
