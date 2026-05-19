# Métricas — Migración a histórico por rango

**Fecha:** 2026-05-19  
**Equipo:** Cuy Sentinel  
**Scope:** Pantalla `/metrics` únicamente. Dashboard no se toca.

---

## Contexto y problema

La pantalla de Métricas usa actualmente `WatchLatestMetricsUseCase` (stream infinito,
datos newest-first) y un `MetricsFilterRow` sin callback. El resultado es:
- Los gráficos de ancho de banda y uptime concatenan listas de dos servicios distintos,
  mezclando timestamps incorrectamente.
- El filtro temporal no hace nada.
- `GetMetricsHistoryUseCase` existe y está registrado en DI pero ningún widget lo consume.

---

## Alcance

**Incluye:**
- Migrar `MetricsCubit` a `GetMetricsHistoryUseCase` con filtro temporal funcional.
- Corrección de agregación temporal en BW y Uptime mediante bucketing real.
- `isRefreshing` para UX no-disruptiva en cambios de rango.
- Extensión de `MetricChartPlaceholder` con soporte de gaps (`List<double?>`).

**Excluye:**
- Dashboard y `DashboardCubit` — ningún cambio.
- `BandwidthChartCard` (widget compartido Dashboard) — ningún cambio.
- fl_chart — no se introduce.
- H3–H9 (backlog auditado) — quedan pendientes.

---

## Decisiones de diseño

| Decisión | Elección | Razón |
|---|---|---|
| Widget de BW para Métricas | Nuevo `MetricsBandwidthChartCard` | Semántica histórica ≠ semántica de Dashboard |
| Gaps en charts | Extender `MetricChartPlaceholder` a `List<double?>` | No introduce fl_chart; backward-compatible |
| BW chart multi-series | `CustomPainter` propio (Y-axis compartido) | Stacking independiente daría escalas distintas |
| Datos faltantes | null en bucket, nunca 0 | Evita caídas artificiales en el gráfico |
| Carga inicial vs recarga | `MetricsLoading` solo al arranque; `isRefreshing` en cambio de rango | UX no disruptiva |
| Orden de datos | Ascendente garantizado en `MetricsCubit` (sort defensivo) | No asumimos orden del repositorio |
| Agregación uptime | Ratio medio `(pb + ck) / 2` | Suma carece de semántica; ratio = fracción disponible |
| Agregación BW | Suma solo si `isComplete` (`pb + ck`); null si falta alguno — no hay campo `combined` precomputado; cada widget calcula su propio agregado | Suma parcial induciría valor erróneo |

---

## Capa de datos

### `MetricsRange` — `lib/presentation/metrics/cubit/metrics_range.dart`

```dart
enum MetricsRange { h1, h6, h24, d7 }

extension MetricsRangeX on MetricsRange {
  Duration get duration => [
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(hours: 24),
    const Duration(days: 7),
  ][index];
  Duration get bucketSize => Duration(milliseconds: duration.inMilliseconds ~/ 12);
  Duration get lookbackTolerance => Duration(
    milliseconds: (bucketSize.inMilliseconds * 1.5).round(),
  );
  String get label => ['1h', '6h', '24h', '7d'][index];
}
```

### `MetricsBucket` — añadir a `metric_model.dart`

```dart
class MetricsBucket {
  const MetricsBucket({required this.time, required this.passbolt, required this.chkmonitor});
  final DateTime time;
  final double? passbolt;
  final double? chkmonitor;

  bool get isComplete => passbolt != null && chkmonitor != null;
  // combined NO existe — cada widget computa su propio agregado
}
```

### `bucketize` — función pura top-level en `metric_model.dart`

Parámetros: `passboltAsc`, `chkmonitorAsc` (se reordenan defensivamente), `from`, `to`,
`range`, `select: double? Function(Metric)`.

Algoritmo por bucket `i` con `start = from + bs*i`, `end = (i==11) ? to : start+bs`:
1. Promedia muestras en `[start, end)` → resultado primario.
2. Si vacío, busca la muestra más reciente en `[start - tolerance, start)` → fallback puntual,
   **no** un promedio de ventana ampliada.
3. Si sigue vacío → `null`.

Ejemplo: bucket 1h/bucket 5min con datos escasos. Si el tramo `[10:00, 10:05)` no tiene
muestras pero hay una en `10:02:30` del tramo anterior (dentro de los 7.5min de tolerancia),
se usa ese valor puntual. Si la muestra más cercana está en `09:50`, cae fuera de la
ventana y el bucket queda `null` (gap visible).

### Extensión en `MetricsLoadedModelX`

```dart
List<MetricsBucket> get bandwidthInBuckets  => bucketize(..., select: (m) => m.bandwidthInMb);
List<MetricsBucket> get bandwidthOutBuckets => bucketize(..., select: (m) => m.bandwidthOutMb);
List<MetricsBucket> get uptimeBuckets       => bucketize(...,
  select: (m) => m.serviceStatus == ServiceStatus.online ? 1.0 : 0.0);
```

---

## Estado y Cubit

### `MetricsLoaded` (actualizado)

Añade: `range: MetricsRange`, `queryFrom: DateTime`, `queryTo: DateTime`,
`isRefreshing: bool = false`, y `MetricsLoaded asRefreshing()`.

`forService()` preservada (usada por `services_tab_view.dart`).

Convención: listas **siempre ascendentes** (sort garantizado en cubit). El caller usa
`lastOrNull` para el valor "actual".

### `MetricsCubit` (reescritura)

- Inyecta `GetMetricsHistoryUseCase` (elimina `WatchLatestMetricsUseCase` y subscripciones).
- `init()` → `_load(MetricsRange.h1)`.
- `changeRange(range)` → guarda `_range`, llama `_load`.
- `_load`:
  - Si estado actual es `MetricsLoaded` → `emit(current.asRefreshing())`.
  - Si no → `emit(MetricsLoading())`.
  - `Future.wait([passbolt, chkmonitor])`, sort defensivo por `collectedAt` ascendente, emit `MetricsLoaded`.

---

## Widgets

### `MetricsFilterRow` (reescritura)

Constructor: `{required MetricsRange selected, required ValueChanged<MetricsRange> onChanged}`.  
Labels: `['1h', '6h', '24h', '7d']`. Layout: `SingleChildScrollView(horizontal) + Row` —
no `Wrap` (orden temporal no debe saltar de línea).

### `MetricChartPlaceholder` (extensión backward-compatible)

Cambio de `List<double>` a `List<double?>`. Los callers existentes no requieren cambios
(Dart covariance: `List<double>` es subtipo de `List<double?>`).

En `_drawSeries`: null → levantar pincel (`path.moveTo` en el siguiente punto no-null);
fill path cierra el segmento anterior antes del gap y abre uno nuevo después.  
En `_normalizeLength`: null → null (no fill; no interpola a través de gaps).  
En `_interpolatePoints`: null en cualquier lado → null (sin transición animada en gaps;
al transicionar hacia/desde un bucket null se produce un `moveTo` brusco — comportamiento
aceptado en v1, mejora de animación queda fuera de scope).

### `MetricsBandwidthChartCard` — nuevo, `lib/presentation/metrics/widgets/`

API: `{required List<MetricsBucket> inBuckets, required List<MetricsBucket> outBuckets}`.

`CustomPainter` propio (en el mismo archivo, privado):
- Normaliza **ambas** series juntas: `maxY = max(todos los valores no-null de ambas listas)`.
- Dos líneas: `AppColors.chartNetwork` (entrada) + `AppColors.secondary` (salida).
- Gap: null → levantar pincel (misma lógica que el placeholder extendido).
- Fill gradient translúcido por serie.
- Mismo grid de 4 líneas horizontales que `MetricChartPlaceholder`.

Agregación del valor a dibujar:
- In: `!b.isComplete ? null : b.passbolt! + b.chkmonitor!`
- Out: ídem con `bandwidthOutMb`.

Leyenda: "Entrante / Saliente (Passbolt + ChkMonitor)".

### `MetricsUptimeCard` (fix)

Recibe `List<MetricsBucket>` (de `uptimeBuckets`). Usa `MetricChartPlaceholder` extendido.  
Conversión a `List<double?>`:
```
(pb?, ck?) → (pb + ck) / 2
(pb?, null) → pb
(null, ck?) → ck
(null, null) → null
```

### `ResourceChartCard` (fix mínimo)

Reemplaza `metrics.reversed.toList()` por sort ascendente por `collectedAt`.  
Seguro para Dashboard: sort de una lista ya ordenada es idempotente.

---

## Wiring

| Archivo | Cambio |
|---|---|
| `metrics_page.dart` | Inyectar `GetMetricsHistoryUseCase` en lugar de `WatchLatestMetricsUseCase` |
| `metrics_content_view.dart` | Pasar `selected`+`onChanged` a `MetricsFilterRow`; usar `MetricsBandwidthChartCard`; pasar `uptimeBuckets` a `MetricsUptimeCard`; `LinearProgressIndicator` cuando `isRefreshing` |
| `metric_model.dart` | `firstOrNull` → `lastOrNull` en `toSummaryCards` y `toSnmpRows` |
| `services_tab_view.dart:49` | `.firstOrNull` → `.lastOrNull` (datos ahora ascendentes) |

---

## Archivos afectados

| Archivo | Tipo de cambio |
|---|---|
| `lib/presentation/metrics/cubit/metrics_range.dart` | Nuevo |
| `lib/presentation/metrics/widgets/metrics_bandwidth_chart_card.dart` | Nuevo |
| `lib/presentation/metrics/cubit/metrics_cubit.dart` | Reescritura |
| `lib/presentation/metrics/cubit/metrics_state.dart` | Actualización |
| `lib/presentation/metrics/metric_model.dart` | Actualización |
| `lib/presentation/metrics/metrics_page.dart` | Un cambio de inyección |
| `lib/presentation/metrics/widgets/metrics_filter_row.dart` | Reescritura |
| `lib/presentation/metrics/views/metrics_content_view.dart` | Actualización de wiring |
| `lib/presentation/metrics/widgets/metrics_uptime_card.dart` | Fix de agregación |
| `lib/presentation/widgets/metric_chart_placeholder.dart` | Extensión nullable |
| `lib/presentation/widgets/resource_chart_card.dart` | Fix de ordenamiento |
| `lib/presentation/services/monitored_services/views/services_tab_view.dart` | `firstOrNull` → `lastOrNull` |

**Sin cambios:** `BandwidthChartCard`, `DashboardCubit`, `DashboardPage`, `DashboardContentView`.

---

## Criterios de aceptación

- `flutter analyze` sin issues.
- Filtro temporal cambia el rango y recarga sin blank-screen.
- `isRefreshing` muestra `LinearProgressIndicator` sin ocultar datos anteriores.
- Buckets nulos se renderizan como gaps visibles, nunca como cero.
- BW chart muestra entrante Y saliente con Y-axis compartido.
- Uptime muestra ratio 0.0–1.0, no suma de servicios.
- Dashboard inalterado (smoke test manual).
