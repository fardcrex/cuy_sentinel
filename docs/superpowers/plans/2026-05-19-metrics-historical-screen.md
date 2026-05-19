# Métricas — Migración a histórico por rango: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrar la pantalla `/metrics` de un stream infinito newest-first a consultas históricas por rango temporal (`GetMetricsHistoryUseCase`), con bucketing real, filtro temporal funcional, y agregación correcta en BW y Uptime.

**Architecture:** `MetricsCubit` reemplaza las dos suscripciones de stream por `Future.wait` sobre `GetMetricsHistoryUseCase`. El estado `MetricsLoaded` almacena listas ascendentes + metadatos de rango. La bucketización es una función pura en `metric_model.dart`; los widgets de Métricas consumen `List<MetricsBucket>` sin tocar Dashboard.

**Tech Stack:** Flutter 3, flutter_bloc, dart:math, CustomPainter canvas (sin fl_chart).

**Spec:** `docs/superpowers/specs/2026-05-19-metrics-historical-screen-design.md`

---

## File map

| Acción | Archivo |
|---|---|
| Crear | `lib/presentation/metrics/cubit/metrics_range.dart` |
| Crear | `lib/presentation/metrics/widgets/metrics_bandwidth_chart_card.dart` |
| Crear | `test/presentation/metrics/metrics_range_test.dart` |
| Crear | `test/presentation/metrics/metric_model_bucket_test.dart` |
| Reescribir | `lib/presentation/metrics/cubit/metrics_cubit.dart` |
| Actualizar | `lib/presentation/metrics/cubit/metrics_state.dart` |
| Actualizar | `lib/presentation/metrics/metric_model.dart` |
| Actualizar | `lib/presentation/metrics/metrics_page.dart` |
| Reescribir | `lib/presentation/metrics/widgets/metrics_filter_row.dart` |
| Actualizar | `lib/presentation/metrics/views/metrics_content_view.dart` |
| Fix | `lib/presentation/metrics/widgets/metrics_uptime_card.dart` |
| Extender | `lib/presentation/widgets/metric_chart_placeholder.dart` |
| Fix 1 línea | `lib/presentation/widgets/resource_chart_card.dart` |
| Fix 1 línea | `lib/presentation/services/services_page.dart` |
| Fix 1 línea | `lib/presentation/services/monitored_services/views/services_tab_view.dart` |

**Sin cambios:** `BandwidthChartCard`, `DashboardCubit`, `DashboardPage`, `DashboardContentView`.

---

## Task 1: MetricsRange enum

**Files:**
- Create: `lib/presentation/metrics/cubit/metrics_range.dart`
- Create: `test/presentation/metrics/metrics_range_test.dart`

- [ ] **Step 1.1: Escribir el test primero**

Crear directorio `test/presentation/metrics/` y el archivo:

```dart
// test/presentation/metrics/metrics_range_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/presentation/metrics/cubit/metrics_range.dart';

void main() {
  group('MetricsRange.bucketSize', () {
    test('h1 → 5 min', () =>
        expect(MetricsRange.h1.bucketSize, const Duration(minutes: 5)));
    test('h6 → 30 min', () =>
        expect(MetricsRange.h6.bucketSize, const Duration(minutes: 30)));
    test('h24 → 2 h', () =>
        expect(MetricsRange.h24.bucketSize, const Duration(hours: 2)));
    test('d7 → 14 h', () =>
        expect(MetricsRange.d7.bucketSize, const Duration(hours: 14)));
  });

  group('MetricsRange.lookbackTolerance', () {
    test('es 1.5× bucketSize para todos los rangos', () {
      for (final range in MetricsRange.values) {
        final expected = Duration(
          milliseconds: (range.bucketSize.inMilliseconds * 1.5).round(),
        );
        expect(range.lookbackTolerance, expected,
            reason: 'fallo en ${range.name}');
      }
    });
  });

  group('MetricsRange.label', () {
    test('labels correctos', () {
      expect(MetricsRange.h1.label, '1h');
      expect(MetricsRange.h6.label, '6h');
      expect(MetricsRange.h24.label, '24h');
      expect(MetricsRange.d7.label, '7d');
    });
  });
}
```

- [ ] **Step 1.2: Correr el test y verificar que falla**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel
flutter test test/presentation/metrics/metrics_range_test.dart
```

Esperado: error de compilación (clase no existe todavía).

- [ ] **Step 1.3: Implementar MetricsRange**

```dart
// lib/presentation/metrics/cubit/metrics_range.dart
enum MetricsRange { h1, h6, h24, d7 }

extension MetricsRangeX on MetricsRange {
  Duration get duration => [
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(hours: 24),
    const Duration(days: 7),
  ][index];

  Duration get bucketSize =>
      Duration(milliseconds: duration.inMilliseconds ~/ 12);

  Duration get lookbackTolerance => Duration(
        milliseconds: (bucketSize.inMilliseconds * 1.5).round(),
      );

  String get label => ['1h', '6h', '24h', '7d'][index];
}
```

- [ ] **Step 1.4: Correr el test y verificar que pasa**

```bash
flutter test test/presentation/metrics/metrics_range_test.dart
```

Esperado: todos los tests pasan.

- [ ] **Step 1.5: Commit**

```bash
git add lib/presentation/metrics/cubit/metrics_range.dart \
        test/presentation/metrics/metrics_range_test.dart
git commit -m "feat: add MetricsRange enum with bucketSize and lookbackTolerance"
```

---

## Task 2: MetricsBucket + bucketize

**Files:**
- Modify: `lib/presentation/metrics/metric_model.dart` (sólo añadir, sin tocar lo existente)
- Create: `test/presentation/metrics/metric_model_bucket_test.dart`

- [ ] **Step 2.1: Escribir el test de bucketize**

```dart
// test/presentation/metrics/metric_model_bucket_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/feature/metrics/domain/entities/metric.dart';
import 'package:cuy_sentinel/feature/monitoring/domain/entities/service_status.dart';
import 'package:cuy_sentinel/presentation/metrics/cubit/metrics_range.dart';
import 'package:cuy_sentinel/presentation/metrics/metric_model.dart';

Metric _m({required DateTime at, double? cpu}) => Metric(
      id: 'test',
      serviceId: 'svc-test',
      cpuUsagePercent: cpu,
      serviceStatus: ServiceStatus.online,
      collectedAt: at,
    );

void main() {
  final from = DateTime(2026, 1, 1, 12, 0);
  final to = DateTime(2026, 1, 1, 13, 0); // 1h → 12 buckets de 5 min
  const range = MetricsRange.h1;

  group('bucketize', () {
    test('siempre retorna exactamente 12 buckets', () {
      final result = bucketize(
        passboltAsc: [],
        chkmonitorAsc: [],
        from: from,
        to: to,
        range: range,
        select: (m) => m.cpuUsagePercent,
      );
      expect(result, hasLength(12));
    });

    test('promedia muestras dentro de la ventana estricta del bucket', () {
      // Bucket 0: [12:00, 12:05)
      final metrics = [
        _m(at: from.add(const Duration(minutes: 1)), cpu: 20),
        _m(at: from.add(const Duration(minutes: 3)), cpu: 40),
      ];
      final result = bucketize(
        passboltAsc: metrics,
        chkmonitorAsc: [],
        from: from,
        to: to,
        range: range,
        select: (m) => m.cpuUsagePercent,
      );
      expect(result.first.passbolt, closeTo(30.0, 0.001));
    });

    test('usa fallback puntual si el bucket está vacío pero hay muestra dentro de la tolerancia', () {
      // Tolerancia h1 = 7.5 min; muestra 30s antes del bucket → dentro de tolerancia
      final metrics = [
        _m(at: from.subtract(const Duration(seconds: 30)), cpu: 55),
      ];
      final result = bucketize(
        passboltAsc: metrics,
        chkmonitorAsc: [],
        from: from,
        to: to,
        range: range,
        select: (m) => m.cpuUsagePercent,
      );
      expect(result.first.passbolt, 55.0);
    });

    test('retorna null cuando no hay dato en el bucket ni en la ventana de tolerancia', () {
      // Muestra 20 min antes → fuera de tolerancia (7.5 min)
      final metrics = [
        _m(at: from.subtract(const Duration(minutes: 20)), cpu: 55),
      ];
      final result = bucketize(
        passboltAsc: metrics,
        chkmonitorAsc: [],
        from: from,
        to: to,
        range: range,
        select: (m) => m.cpuUsagePercent,
      );
      expect(result.first.passbolt, isNull);
    });

    test('rellena passbolt y chkmonitor independientemente', () {
      final pb = [_m(at: from.add(const Duration(minutes: 1)), cpu: 10)];
      final ck = [_m(at: from.add(const Duration(minutes: 2)), cpu: 90)];
      final result = bucketize(
        passboltAsc: pb,
        chkmonitorAsc: ck,
        from: from,
        to: to,
        range: range,
        select: (m) => m.cpuUsagePercent,
      );
      expect(result.first.passbolt, 10.0);
      expect(result.first.chkmonitor, 90.0);
    });

    test('el último bucket cierra en `to`', () {
      final result = bucketize(
        passboltAsc: [],
        chkmonitorAsc: [],
        from: from,
        to: to,
        range: range,
        select: (m) => m.cpuUsagePercent,
      );
      expect(result.last.time, from.add(range.bucketSize * 11));
    });
  });

  group('MetricsBucket', () {
    test('isComplete true cuando ambos no-null', () {
      final b = MetricsBucket(
          time: DateTime.now(), passbolt: 1.0, chkmonitor: 2.0);
      expect(b.isComplete, isTrue);
    });

    test('isComplete false si passbolt es null', () {
      expect(
        MetricsBucket(time: DateTime.now(), passbolt: null, chkmonitor: 2.0)
            .isComplete,
        isFalse,
      );
    });

    test('isComplete false si chkmonitor es null', () {
      expect(
        MetricsBucket(time: DateTime.now(), passbolt: 1.0, chkmonitor: null)
            .isComplete,
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2.2: Correr el test y verificar que falla**

```bash
flutter test test/presentation/metrics/metric_model_bucket_test.dart
```

Esperado: error de compilación (`MetricsBucket` y `bucketize` no existen).

- [ ] **Step 2.3: Añadir MetricsBucket y bucketize a metric_model.dart**

Al inicio de `lib/presentation/metrics/metric_model.dart`, después de los imports existentes, insertar:

```dart
import 'cubit/metrics_range.dart';
```

Luego añadir justo después del bloque de imports (antes de los comentarios `// ── models`):

```dart
// ── bucket model ──────────────────────────────────────────────────────────────

class MetricsBucket {
  const MetricsBucket({
    required this.time,
    required this.passbolt,
    required this.chkmonitor,
  });

  final DateTime time;
  final double? passbolt;
  final double? chkmonitor;

  bool get isComplete => passbolt != null && chkmonitor != null;
  // No hay combined: cada widget calcula su propio agregado según semántica
}

// ── bucketizer ────────────────────────────────────────────────────────────────

List<MetricsBucket> bucketize({
  required List<Metric> passboltAsc,
  required List<Metric> chkmonitorAsc,
  required DateTime from,
  required DateTime to,
  required MetricsRange range,
  required double? Function(Metric) select,
}) {
  final pb = [...passboltAsc]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
  final ck = [...chkmonitorAsc]
    ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));

  final bs = range.bucketSize;
  final tol = range.lookbackTolerance;

  double? _avg(List<Metric> src, DateTime start, DateTime end) {
    final values = src
        .where((m) =>
            !m.collectedAt.isBefore(start) && m.collectedAt.isBefore(end))
        .map(select)
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double? _nearest(List<Metric> src, DateTime start) {
    final candidates = src
        .where((m) =>
            !m.collectedAt.isBefore(start.subtract(tol)) &&
            m.collectedAt.isBefore(start))
        .toList();
    if (candidates.isEmpty) return null;
    return select(candidates.last);
  }

  return List.generate(12, (i) {
    final start = from.add(bs * i);
    final end = (i == 11) ? to : start.add(bs);

    final pbVal = _avg(pb, start, end) ?? _nearest(pb, start);
    final ckVal = _avg(ck, start, end) ?? _nearest(ck, start);

    return MetricsBucket(time: start, passbolt: pbVal, chkmonitor: ckVal);
  });
}
```

El import necesario para `Metric` ya existe en el archivo; `MetricsRange` se importa con la línea añadida arriba.

- [ ] **Step 2.4: Correr el test y verificar que pasa**

```bash
flutter test test/presentation/metrics/metric_model_bucket_test.dart
```

Esperado: todos los tests pasan.

- [ ] **Step 2.5: flutter analyze (sin errores)**

```bash
flutter analyze lib/presentation/metrics/metric_model.dart \
               lib/presentation/metrics/cubit/metrics_range.dart
```

- [ ] **Step 2.6: Commit**

```bash
git add lib/presentation/metrics/metric_model.dart \
        test/presentation/metrics/metric_model_bucket_test.dart
git commit -m "feat: add MetricsBucket and bucketize to metric_model"
```

---

## Task 3: MetricsState — añadir range, queryFrom, queryTo, isRefreshing

**Files:**
- Modify: `lib/presentation/metrics/cubit/metrics_state.dart`

- [ ] **Step 3.1: Reemplazar el contenido completo del archivo**

```dart
// lib/presentation/metrics/cubit/metrics_state.dart
import '../../../feature/metrics/domain/entities/metric.dart';
import 'metrics_range.dart';

sealed class MetricsState {
  const MetricsState();
}

final class MetricsInitial extends MetricsState {
  const MetricsInitial();
}

final class MetricsLoading extends MetricsState {
  const MetricsLoading();
}

final class MetricsLoaded extends MetricsState {
  const MetricsLoaded({
    required this.passboltMetrics,
    required this.chkmonitorMetrics,
    required this.range,
    required this.queryFrom,
    required this.queryTo,
    this.isRefreshing = false,
  });

  /// Ascendente: índice 0 = más antiguo, last = más reciente.
  final List<Metric> passboltMetrics;
  final List<Metric> chkmonitorMetrics;
  final MetricsRange range;
  final DateTime queryFrom;
  final DateTime queryTo;
  final bool isRefreshing;

  MetricsLoaded asRefreshing() => MetricsLoaded(
        passboltMetrics: passboltMetrics,
        chkmonitorMetrics: chkmonitorMetrics,
        range: range,
        queryFrom: queryFrom,
        queryTo: queryTo,
        isRefreshing: true,
      );

  /// Preservado — usado por services_tab_view.dart.
  List<Metric> forService(String serviceId) => switch (serviceId) {
        'svc-passbolt' => passboltMetrics,
        'svc-chkmonitor' => chkmonitorMetrics,
        _ => const [],
      };
}

final class MetricsError extends MetricsState {
  const MetricsError({required this.message});
  final String message;
}
```

- [ ] **Step 3.2: Verificar que el archivo compila**

```bash
flutter analyze lib/presentation/metrics/cubit/metrics_state.dart
```

Esperado: 0 issues en ese archivo (el cubit todavía falla porque usa la API vieja — está bien).

- [ ] **Step 3.3: Commit**

```bash
git add lib/presentation/metrics/cubit/metrics_state.dart
git commit -m "feat: update MetricsLoaded with range, queryFrom/To, isRefreshing"
```

---

## Task 4: MetricsCubit — reescritura

**Files:**
- Modify: `lib/presentation/metrics/cubit/metrics_cubit.dart`

- [ ] **Step 4.1: Reemplazar el contenido completo del archivo**

```dart
// lib/presentation/metrics/cubit/metrics_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/metrics/application/get_metrics_history_use_case.dart';
import 'metrics_range.dart';
import 'metrics_state.dart';

class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit({required GetMetricsHistoryUseCase getHistory})
      : _getHistory = getHistory,
        super(const MetricsInitial());

  final GetMetricsHistoryUseCase _getHistory;
  MetricsRange _range = MetricsRange.h1;

  void init() => _load(_range);

  void changeRange(MetricsRange range) {
    if (_range == range) return;
    _range = range;
    _load(range);
  }

  Future<void> _load(MetricsRange range) async {
    final current = state;
    if (current is MetricsLoaded) {
      emit(current.asRefreshing());
    } else {
      emit(const MetricsLoading());
    }

    try {
      final to = DateTime.now();
      final from = to.subtract(range.duration);

      final results = await Future.wait([
        _getHistory.execute(serviceId: 'svc-passbolt', from: from, to: to),
        _getHistory.execute(serviceId: 'svc-chkmonitor', from: from, to: to),
      ]);

      final passbolt = [...results[0]]
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
      final chkmonitor = [...results[1]]
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));

      emit(MetricsLoaded(
        passboltMetrics: passbolt,
        chkmonitorMetrics: chkmonitor,
        range: range,
        queryFrom: from,
        queryTo: to,
      ));
    } catch (e) {
      emit(MetricsError(message: e.toString()));
    }
  }
}
```

- [ ] **Step 4.2: Correr analyze para verificar que cubit compila**

```bash
flutter analyze lib/presentation/metrics/cubit/
```

Esperado: 0 issues en el cubit (metrics_page.dart y services_page.dart fallarán todavía — se arreglan en Task 11).

- [ ] **Step 4.3: Test de integración del cubit**

Crear `test/presentation/metrics/metrics_cubit_test.dart`:

```dart
// test/presentation/metrics/metrics_cubit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/feature/metrics/application/get_metrics_history_use_case.dart';
import 'package:cuy_sentinel/feature/metrics/infrastructure/in_memory_metrics_repository.dart';
import 'package:cuy_sentinel/presentation/metrics/cubit/metrics_cubit.dart';
import 'package:cuy_sentinel/presentation/metrics/cubit/metrics_range.dart';
import 'package:cuy_sentinel/presentation/metrics/cubit/metrics_state.dart';

void main() {
  late MetricsCubit cubit;

  setUp(() {
    cubit = MetricsCubit(
      getHistory: GetMetricsHistoryUseCase(InMemoryMetricsRepository()),
    );
  });

  tearDown(() => cubit.close());

  test('estado inicial es MetricsInitial', () {
    expect(cubit.state, isA<MetricsInitial>());
  });

  test('init emite MetricsLoading luego MetricsLoaded', () async {
    expectLater(
      cubit.stream,
      emitsInOrder([isA<MetricsLoading>(), isA<MetricsLoaded>()]),
    );
    cubit.init();
    await Future.delayed(const Duration(milliseconds: 200));
  });

  test('MetricsLoaded tiene listas ascendentes', () async {
    cubit.init();
    await Future.delayed(const Duration(milliseconds: 200));
    final loaded = cubit.state as MetricsLoaded;
    final pb = loaded.passboltMetrics;
    for (var i = 1; i < pb.length; i++) {
      expect(
        pb[i].collectedAt.isAfter(pb[i - 1].collectedAt) ||
            pb[i].collectedAt == pb[i - 1].collectedAt,
        isTrue,
        reason: 'índice $i no está en orden ascendente',
      );
    }
  });

  test('changeRange con estado loaded emite isRefreshing=true primero', () async {
    cubit.init();
    await Future.delayed(const Duration(milliseconds: 200));
    expect(cubit.state, isA<MetricsLoaded>());

    final emittedStates = <MetricsState>[];
    cubit.stream.listen(emittedStates.add);

    cubit.changeRange(MetricsRange.h6);
    await Future.delayed(const Duration(milliseconds: 200));

    expect(emittedStates.first, isA<MetricsLoaded>());
    expect((emittedStates.first as MetricsLoaded).isRefreshing, isTrue);
    expect((emittedStates.last as MetricsLoaded).range, MetricsRange.h6);
    expect((emittedStates.last as MetricsLoaded).isRefreshing, isFalse);
  });
}
```

- [ ] **Step 4.4: Correr el test del cubit**

```bash
flutter test test/presentation/metrics/metrics_cubit_test.dart
```

Esperado: todos pasan.

- [ ] **Step 4.5: Commit**

```bash
git add lib/presentation/metrics/cubit/metrics_cubit.dart \
        test/presentation/metrics/metrics_cubit_test.dart
git commit -m "feat: rewrite MetricsCubit using GetMetricsHistoryUseCase with isRefreshing"
```

---

## Task 5: metric_model.dart — extension getters + firstOrNull→lastOrNull

**Files:**
- Modify: `lib/presentation/metrics/metric_model.dart`

- [ ] **Step 5.1: Actualizar toSummaryCards() y toSnmpRows() en MetricsLoadedModelX**

En `metric_model.dart`, localizar `extension MetricsLoadedModelX on MetricsLoaded`. Cambiar las dos líneas con `firstOrNull`:

```dart
// ANTES — en toSummaryCards():
final pb = passboltMetrics.firstOrNull;
final ck = chkmonitorMetrics.firstOrNull;

// DESPUÉS:
final pb = passboltMetrics.lastOrNull;
final ck = chkmonitorMetrics.lastOrNull;
```

```dart
// ANTES — en toSnmpRows():
final pb = passboltMetrics.firstOrNull;
final ck = chkmonitorMetrics.firstOrNull;

// DESPUÉS:
final pb = passboltMetrics.lastOrNull;
final ck = chkmonitorMetrics.lastOrNull;
```

- [ ] **Step 5.2: Añadir los tres getters de buckets a MetricsLoadedModelX**

Al final de `extension MetricsLoadedModelX on MetricsLoaded { ... }`, antes del cierre `}`, añadir:

```dart
  List<MetricsBucket> get bandwidthInBuckets => bucketize(
        passboltAsc: passboltMetrics,
        chkmonitorAsc: chkmonitorMetrics,
        from: queryFrom,
        to: queryTo,
        range: range,
        select: (m) => m.bandwidthInMb,
      );

  List<MetricsBucket> get bandwidthOutBuckets => bucketize(
        passboltAsc: passboltMetrics,
        chkmonitorAsc: chkmonitorMetrics,
        from: queryFrom,
        to: queryTo,
        range: range,
        select: (m) => m.bandwidthOutMb,
      );

  List<MetricsBucket> get uptimeBuckets => bucketize(
        passboltAsc: passboltMetrics,
        chkmonitorAsc: chkmonitorMetrics,
        from: queryFrom,
        to: queryTo,
        range: range,
        select: (m) => m.serviceStatus == ServiceStatus.online ? 1.0 : 0.0,
      );
```

El import de `ServiceStatus` ya existe en el archivo.

- [ ] **Step 5.3: Verificar que compila**

```bash
flutter analyze lib/presentation/metrics/metric_model.dart
```

Esperado: 0 issues.

- [ ] **Step 5.4: Commit**

```bash
git add lib/presentation/metrics/metric_model.dart
git commit -m "feat: add bandwidthInBuckets/bandwidthOutBuckets/uptimeBuckets to MetricsLoadedModelX, fix firstOrNull→lastOrNull"
```

---

## Task 6: MetricChartPlaceholder — extender a List<double?>

**Files:**
- Modify: `lib/presentation/widgets/metric_chart_placeholder.dart`

- [ ] **Step 6.1: Reemplazar el contenido completo del archivo**

```dart
// lib/presentation/widgets/metric_chart_placeholder.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Renderizador de línea animado. Acepta [List<double?>]:
/// - double: valor normalizado [0, 1] para esa posición
/// - null: gap visible (pincel levantado)
///
/// Backward-compatible: List<double> es subtipo de List<double?> en Dart.
class MetricChartPlaceholder extends StatefulWidget {
  const MetricChartPlaceholder({
    super.key,
    required this.points,
    required this.lineColor,
    this.height = 180,
    this.duration = const Duration(milliseconds: 700),
  });

  final List<double?> points;
  final Color lineColor;
  final double height;
  final Duration duration;

  @override
  State<MetricChartPlaceholder> createState() =>
      _MetricChartPlaceholderState();
}

class _MetricChartPlaceholderState extends State<MetricChartPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<double?> _fromPoints;
  late List<double?> _toPoints;
  var _useSlidingWindowTransition = false;

  @override
  void initState() {
    super.initState();
    _fromPoints = List<double?>.from(widget.points);
    _toPoints = List<double?>.from(widget.points);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant MetricChartPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (!_samePoints(oldWidget.points, widget.points)) {
      _fromPoints = _interpolatePoints(_controller.value);
      _toPoints = List<double?>.from(widget.points);
      _useSlidingWindowTransition =
          _isSlidingWindowUpdate(oldWidget.points, widget.points);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
        builder: (context, child) {
          final progress =
              Curves.easeOutCubic.transform(_controller.value);
          return CustomPaint(
            painter: _LineChartPainter(
              fromPoints: _fromPoints,
              toPoints: _toPoints,
              lineColor: widget.lineColor,
              progress: progress,
              useSlidingWindowTransition: _useSlidingWindowTransition,
            ),
          );
        },
      ),
    );
  }

  bool _samePoints(List<double?> a, List<double?> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<double?> _interpolatePoints(double progress) {
    final targetLen = _fromPoints.length > _toPoints.length
        ? _fromPoints.length
        : _toPoints.length;
    if (targetLen == 0) return const [];
    final from = _normalizeLength(_fromPoints, targetLen);
    final to = _normalizeLength(_toPoints, targetLen);
    return List<double?>.generate(targetLen, (i) {
      final f = from[i];
      final t = to[i];
      if (f == null || t == null) return null;
      return f + ((t - f) * progress);
    });
  }

  List<double?> _normalizeLength(List<double?> source, int targetLen) {
    if (source.isEmpty) return List<double?>.filled(targetLen, null);
    if (source.length == targetLen) return List<double?>.from(source);
    if (source.length > targetLen) {
      return source.take(targetLen).toList();
    }
    return List<double?>.filled(targetLen - source.length, source.first) +
        source;
  }

  bool _isSlidingWindowUpdate(List<double?> previous, List<double?> next) {
    if (previous.length != next.length || previous.length < 2) return false;
    for (var i = 0; i < previous.length - 1; i++) {
      final prev = previous[i + 1];
      final nxt = next[i];
      if (prev == null || nxt == null) return false;
      if ((prev - nxt).abs() > 0.0001) return false;
    }
    return true;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.fromPoints,
    required this.toPoints,
    required this.lineColor,
    required this.progress,
    required this.useSlidingWindowTransition,
  });

  final List<double?> fromPoints;
  final List<double?> toPoints;
  final Color lineColor;
  final double progress;
  final bool useSlidingWindowTransition;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final targetLen = fromPoints.length > toPoints.length
        ? fromPoints.length
        : toPoints.length;
    if (targetLen == 0) {
      canvas.restore();
      return;
    }

    final normFrom = _normalizeLength(fromPoints, targetLen);
    final normTo = _normalizeLength(toPoints, targetLen);

    final gridPaint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final dy = size.height * (i / 3);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final stepX =
        targetLen <= 1 ? 0.0 : size.width / (targetLen - 1);
    final oldShift = -stepX * progress;
    final newShift = stepX * (1 - progress);

    final oldLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 1 - progress)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final newLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint _fillPaint(double alpha) => Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.24 * alpha),
          lineColor.withValues(alpha: 0.02 * alpha),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    if (useSlidingWindowTransition && progress < 1) {
      _drawSeries(canvas, size, normFrom, oldShift, _fillPaint(1 - progress),
          oldLinePaint);
    }

    if (useSlidingWindowTransition) {
      _drawSeries(canvas, size, normTo, newShift, _fillPaint(progress),
          newLinePaint);
    } else {
      final interpolated = List<double?>.generate(targetLen, (i) {
        final f = normFrom[i];
        final t = normTo[i];
        if (f == null || t == null) return null;
        return f + ((t - f) * progress);
      });
      _drawSeries(canvas, size, interpolated, 0, _fillPaint(1.0),
          newLinePaint);
    }

    canvas.restore();
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    List<double?> points,
    double hShift,
    Paint fillPaint,
    Paint linePaint,
  ) {
    if (points.isEmpty) return;
    final n = points.length;
    var linePath = Path();
    var fillPath = Path();
    var segmentStarted = false;
    var lastDx = 0.0;

    void closeSegment() {
      if (!segmentStarted) return;
      fillPath
        ..lineTo(lastDx, size.height)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
      linePath = Path();
      fillPath = Path();
      segmentStarted = false;
    }

    for (var i = 0; i < n; i++) {
      final value = points[i];
      final dx =
          (n == 1 ? 0.0 : (size.width * i / (n - 1))) + hShift;

      if (value == null) {
        closeSegment();
        continue;
      }

      final dy = size.height - (size.height * value);
      if (!segmentStarted) {
        linePath.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, size.height)
          ..lineTo(dx, dy);
        segmentStarted = true;
      } else {
        linePath.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
      lastDx = dx;
    }
    closeSegment();
  }

  List<double?> _normalizeLength(List<double?> source, int targetLen) {
    if (source.isEmpty) return List<double?>.filled(targetLen, null);
    if (source.length == targetLen) return List<double?>.from(source);
    if (source.length > targetLen) {
      return source.take(targetLen).toList();
    }
    return List<double?>.filled(targetLen - source.length, source.first) +
        source;
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.fromPoints != fromPoints ||
      old.toPoints != toPoints ||
      old.lineColor != lineColor ||
      old.progress != progress ||
      old.useSlidingWindowTransition != useSlidingWindowTransition;
}
```

- [ ] **Step 6.2: Verificar que todos los callers existentes siguen compilando**

```bash
flutter analyze lib/presentation/widgets/resource_chart_card.dart \
               lib/presentation/widgets/bandwidth_chart_card.dart \
               lib/presentation/metrics/widgets/metrics_uptime_card.dart
```

Esperado: 0 errores de tipo (los callers pasan `List<double>` que es subtipo de `List<double?>`).

- [ ] **Step 6.3: Commit**

```bash
git add lib/presentation/widgets/metric_chart_placeholder.dart
git commit -m "feat: extend MetricChartPlaceholder to support List<double?> with gap rendering"
```

---

## Task 7: MetricsFilterRow — reescritura

**Files:**
- Modify: `lib/presentation/metrics/widgets/metrics_filter_row.dart`

- [ ] **Step 7.1: Reemplazar el contenido completo del archivo**

```dart
// lib/presentation/metrics/widgets/metrics_filter_row.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../cubit/metrics_range.dart';

class MetricsFilterRow extends StatelessWidget {
  const MetricsFilterRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MetricsRange selected;
  final ValueChanged<MetricsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final range in MetricsRange.values)
              GestureDetector(
                onTap: () => onChanged(range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected == range
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    range.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected == range
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.2: Verificar que compila**

```bash
flutter analyze lib/presentation/metrics/widgets/metrics_filter_row.dart
```

- [ ] **Step 7.3: Commit**

```bash
git add lib/presentation/metrics/widgets/metrics_filter_row.dart
git commit -m "feat: rewrite MetricsFilterRow with MetricsRange enum and scroll horizontal"
```

---

## Task 8: MetricsBandwidthChartCard — widget nuevo

**Files:**
- Create: `lib/presentation/metrics/widgets/metrics_bandwidth_chart_card.dart`

- [ ] **Step 8.1: Crear el archivo**

```dart
// lib/presentation/metrics/widgets/metrics_bandwidth_chart_card.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/animated_number_text.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_stats_row.dart';
import '../metric_model.dart';

class MetricsBandwidthChartCard extends StatelessWidget {
  const MetricsBandwidthChartCard({
    super.key,
    required this.inBuckets,
    required this.outBuckets,
  });

  /// bandwidthInBuckets de MetricsLoadedModelX
  final List<MetricsBucket> inBuckets;

  /// bandwidthOutBuckets de MetricsLoadedModelX
  final List<MetricsBucket> outBuckets;

  @override
  Widget build(BuildContext context) {
    final inValues = _toValues(inBuckets);
    final outValues = _toValues(outBuckets);

    // Y-axis compartido entre ambas series
    final allNonNull = [
      ...inValues.whereType<double>(),
      ...outValues.whereType<double>(),
    ];
    final maxY = allNonNull.isEmpty ? 1.0 : allNonNull.reduce(math.max);

    final inStats = _buildStats(inValues.whereType<double>().toList());
    final outStats = _buildStats(outValues.whereType<double>().toList());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ancho de banda',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Entrante / Saliente (Passbolt + ChkMonitor)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          _SeriesLabel(label: 'Entrante', color: AppColors.chartNetwork),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _BandwidthPainter(
                values: inValues,
                maxY: maxY,
                lineColor: AppColors.chartNetwork,
              ),
            ),
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: _statWidget(inStats.min),
            avg: _statWidget(inStats.avg),
            max: _statWidget(inStats.max),
            color: AppColors.chartNetwork,
          ),
          const SizedBox(height: 20),
          _SeriesLabel(label: 'Saliente', color: AppColors.secondary),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _BandwidthPainter(
                values: outValues,
                maxY: maxY,
                lineColor: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          MetricStatsRow(
            min: _statWidget(outStats.min),
            avg: _statWidget(outStats.avg),
            max: _statWidget(outStats.max),
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  /// null si el bucket no tiene ambos servicios (isComplete=false → gap)
  List<double?> _toValues(List<MetricsBucket> buckets) =>
      buckets.map((b) => b.isComplete ? b.passbolt! + b.chkmonitor! : null).toList();

  _BwStats _buildStats(List<double> values) {
    if (values.isEmpty) return const _BwStats();
    final sorted = [...values]..sort();
    final avg = sorted.reduce((a, b) => a + b) / sorted.length;
    return _BwStats(min: sorted.first, avg: avg, max: sorted.last);
  }

  Widget _statWidget(double? value) {
    if (value == null) return const Text('—');
    return AnimatedNumberText(value: value, decimalDigits: 1, suffix: ' MB/s');
  }
}

// ── painter ───────────────────────────────────────────────────────────────────

class _BandwidthPainter extends CustomPainter {
  const _BandwidthPainter({
    required this.values,
    required this.maxY,
    required this.lineColor,
  });

  final List<double?> values;
  final double maxY;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || values.isEmpty) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final gridPaint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * (i / 3)),
        Offset(size.width, size.height * (i / 3)),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.24),
          lineColor.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    _drawWithGaps(canvas, size, linePaint, fillPaint);
    canvas.restore();
  }

  void _drawWithGaps(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint fillPaint,
  ) {
    final safeMax = maxY <= 0 ? 1.0 : maxY;
    final n = values.length;
    var linePath = Path();
    var fillPath = Path();
    var segmentStarted = false;
    var lastDx = 0.0;

    void closeSegment() {
      if (!segmentStarted) return;
      fillPath
        ..lineTo(lastDx, size.height)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
      linePath = Path();
      fillPath = Path();
      segmentStarted = false;
    }

    for (var i = 0; i < n; i++) {
      final value = values[i];
      final dx = n == 1 ? 0.0 : size.width * i / (n - 1);

      if (value == null) {
        closeSegment();
        continue;
      }

      final normalized = (value / safeMax).clamp(0.0, 1.0);
      final dy = size.height - size.height * normalized;

      if (!segmentStarted) {
        linePath.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, size.height)
          ..lineTo(dx, dy);
        segmentStarted = true;
      } else {
        linePath.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
      lastDx = dx;
    }
    closeSegment();
  }

  @override
  bool shouldRepaint(covariant _BandwidthPainter old) =>
      old.values != values ||
      old.maxY != maxY ||
      old.lineColor != lineColor;
}

// ── helpers ───────────────────────────────────────────────────────────────────

class _BwStats {
  const _BwStats({this.min, this.avg, this.max});
  final double? min;
  final double? avg;
  final double? max;
}

class _SeriesLabel extends StatelessWidget {
  const _SeriesLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
```

- [ ] **Step 8.2: Verificar que compila**

```bash
flutter analyze lib/presentation/metrics/widgets/metrics_bandwidth_chart_card.dart
```

- [ ] **Step 8.3: Commit**

```bash
git add lib/presentation/metrics/widgets/metrics_bandwidth_chart_card.dart
git commit -m "feat: add MetricsBandwidthChartCard with bucket-based aggregation and gap rendering"
```

---

## Task 9: MetricsUptimeCard — fix de agregación

**Files:**
- Modify: `lib/presentation/metrics/widgets/metrics_uptime_card.dart`

- [ ] **Step 9.1: Reemplazar el contenido completo del archivo**

```dart
// lib/presentation/metrics/widgets/metrics_uptime_card.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/animated_number_text.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_chart_placeholder.dart';
import '../../widgets/metric_stats_row.dart';
import '../metric_model.dart';

class MetricsUptimeCard extends StatelessWidget {
  const MetricsUptimeCard({
    super.key,
    required this.buckets,
  });

  /// uptimeBuckets de MetricsLoadedModelX — valores en [0.0, 1.0], null = gap
  final List<MetricsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final ratios = buckets.map(_uptimeRatio).toList();
    final stats = _buildStats(ratios.whereType<double>().toList());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de disponibilidad',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ratio de disponibilidad combinado',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          MetricChartPlaceholder(
            points: ratios,
            lineColor: AppColors.primary,
            height: 140,
          ),
          const SizedBox(height: 14),
          MetricStatsRow(
            min: _statWidget(stats.min),
            avg: _statWidget(stats.avg),
            max: _statWidget(stats.max),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Ratio medio: (pb + ck) / 2 cuando ambos disponibles
  double? _uptimeRatio(MetricsBucket b) => switch ((b.passbolt, b.chkmonitor)) {
        (final pb?, final ck?) => (pb + ck) / 2,
        (final pb?, null) => pb,
        (null, final ck?) => ck,
        (null, null) => null,
      };

  _UptimeStats _buildStats(List<double> values) {
    if (values.isEmpty) return const _UptimeStats();
    final percents = values.map((v) => v * 100).toList()..sort();
    final avg = percents.reduce((a, b) => a + b) / percents.length;
    return _UptimeStats(min: percents.first, avg: avg, max: percents.last);
  }

  Widget _statWidget(double? value) {
    if (value == null) return const Text('—');
    return AnimatedNumberText(value: value, decimalDigits: 1, suffix: '%');
  }
}

class _UptimeStats {
  const _UptimeStats({this.min, this.avg, this.max});
  final double? min;
  final double? avg;
  final double? max;
}
```

- [ ] **Step 9.2: Verificar que compila**

```bash
flutter analyze lib/presentation/metrics/widgets/metrics_uptime_card.dart
```

- [ ] **Step 9.3: Commit**

```bash
git add lib/presentation/metrics/widgets/metrics_uptime_card.dart
git commit -m "fix: MetricsUptimeCard uses bucket-based ratio aggregation"
```

---

## Task 10: ResourceChartCard — fix de ordenamiento

**Files:**
- Modify: `lib/presentation/widgets/resource_chart_card.dart`

- [ ] **Step 10.1: Reemplazar `metrics.reversed` por sort ascendente**

Localizar el método `_buildPoints` en `_ResourceChartCardState`. Cambiar:

```dart
// ANTES
final values = metrics.reversed
    .map((metric) => _metricValue(metric, metricIndex))
    .whereType<double>()
    .map((value) => (value / 100).clamp(0.0, 1.0))
    .toList();

// DESPUÉS
final sorted = [...metrics]
  ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
final values = sorted
    .map((metric) => _metricValue(metric, metricIndex))
    .whereType<double>()
    .map((value) => (value / 100).clamp(0.0, 1.0))
    .toList();
```

- [ ] **Step 10.2: Verificar que compila y que Dashboard no se rompe**

```bash
flutter analyze lib/presentation/widgets/resource_chart_card.dart
```

- [ ] **Step 10.3: Commit**

```bash
git add lib/presentation/widgets/resource_chart_card.dart
git commit -m "fix: ResourceChartCard sort metrics by collectedAt ascending"
```

---

## Task 11: Inyección — metrics_page.dart y services_page.dart

**Files:**
- Modify: `lib/presentation/metrics/metrics_page.dart`
- Modify: `lib/presentation/services/services_page.dart`

- [ ] **Step 11.1: Actualizar metrics_page.dart**

Reemplazar el contenido completo:

```dart
// lib/presentation/metrics/metrics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/metrics/application/get_metrics_history_use_case.dart';
import 'cubit/metrics_cubit.dart';
import 'cubit/metrics_state.dart';
import 'views/metrics_content_view.dart';
import 'views/metrics_error_view.dart';
import 'views/metrics_loading_view.dart';

class MetricsProviderPage extends StatelessWidget {
  const MetricsProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MetricsCubit>(
      create: (ctx) => MetricsCubit(
        getHistory: ctx.read<GetMetricsHistoryUseCase>(),
      )..init(),
      child: const MetricsPage(),
    );
  }
}

class MetricsPage extends StatelessWidget {
  const MetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(
      builder: (context, state) => switch (state) {
        MetricsInitial() || MetricsLoading() => const MetricsLoadingView(),
        MetricsError(:final message) => MetricsErrorView(message: message),
        MetricsLoaded() => MetricsContentView(state: state),
      },
    );
  }
}
```

- [ ] **Step 11.2: Actualizar services_page.dart**

Localizar las líneas del `BlocProvider<MetricsCubit>` (líneas ~34-38) y cambiar:

```dart
// ANTES — en ServicesProviderPage.build():
BlocProvider<MetricsCubit>(
  create: (ctx) => MetricsCubit(
    watchMetrics: ctx.read<WatchLatestMetricsUseCase>(),
  )..init(),
),

// DESPUÉS:
BlocProvider<MetricsCubit>(
  create: (ctx) => MetricsCubit(
    getHistory: ctx.read<GetMetricsHistoryUseCase>(),
  )..init(),
),
```

Y en los imports de `services_page.dart`, reemplazar:
```dart
// ANTES
import '../../feature/metrics/application/get_latest_metrics_use_case.dart';

// DESPUÉS
import '../../feature/metrics/application/get_metrics_history_use_case.dart';
```

- [ ] **Step 11.3: Verificar que ambas páginas compilan**

```bash
flutter analyze lib/presentation/metrics/metrics_page.dart \
               lib/presentation/services/services_page.dart
```

- [ ] **Step 11.4: Commit**

```bash
git add lib/presentation/metrics/metrics_page.dart \
        lib/presentation/services/services_page.dart
git commit -m "fix: inject GetMetricsHistoryUseCase in MetricsProviderPage and ServicesProviderPage"
```

---

## Task 12: Wiring final — content view y services tab

**Files:**
- Modify: `lib/presentation/metrics/views/metrics_content_view.dart`
- Modify: `lib/presentation/services/monitored_services/views/services_tab_view.dart`

- [ ] **Step 12.1: Reemplazar metrics_content_view.dart**

```dart
// lib/presentation/metrics/views/metrics_content_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../widgets/resource_chart_card.dart';
import '../../widgets/screen_header.dart';
import '../cubit/metrics_cubit.dart';
import '../cubit/metrics_state.dart';
import '../metric_model.dart';
import '../widgets/metrics_bandwidth_chart_card.dart';
import '../widgets/metrics_filter_row.dart';
import '../widgets/metrics_snmp_health_card.dart';
import '../widgets/metrics_summary_grid.dart';
import '../widgets/metrics_uptime_card.dart';

class MetricsContentView extends StatelessWidget {
  const MetricsContentView({super.key, required this.state});

  final MetricsLoaded state;

  @override
  Widget build(BuildContext context) {
    final summaryCards = state.toSummaryCards();
    final snmpRows = state.toSnmpRows();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final isWide = AppBreakpoints.isDesktop(width);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Métricas',
                subtitle:
                    'Histórico de rendimiento recolectado vía SNMP cada 5 min',
                trailing: MetricsFilterRow(
                  selected: state.range,
                  onChanged: context.read<MetricsCubit>().changeRange,
                ),
              ),
              // Barra de 2px reservada siempre para evitar jitter de layout
              SizedBox(
                height: 2,
                child: state.isRefreshing
                    ? const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              MetricsSummaryGrid(cards: summaryCards),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          ResourceChartCard(
                            passboltMetrics: state.passboltMetrics,
                            chkmonitorMetrics: state.chkmonitorMetrics,
                          ),
                          const SizedBox(height: 20),
                          MetricsBandwidthChartCard(
                            inBuckets: state.bandwidthInBuckets,
                            outBuckets: state.bandwidthOutBuckets,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          MetricsUptimeCard(buckets: state.uptimeBuckets),
                          const SizedBox(height: 20),
                          MetricsSnmpHealthCard(rows: snmpRows),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    ResourceChartCard(
                      passboltMetrics: state.passboltMetrics,
                      chkmonitorMetrics: state.chkmonitorMetrics,
                    ),
                    const SizedBox(height: 20),
                    MetricsBandwidthChartCard(
                      inBuckets: state.bandwidthInBuckets,
                      outBuckets: state.bandwidthOutBuckets,
                    ),
                    const SizedBox(height: 20),
                    MetricsUptimeCard(buckets: state.uptimeBuckets),
                    const SizedBox(height: 20),
                    MetricsSnmpHealthCard(rows: snmpRows),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 12.2: Corregir services_tab_view.dart — firstOrNull → lastOrNull**

Localizar la línea 49:

```dart
// ANTES
.map((s) => s.toModel(metrics.forService(s.id).firstOrNull))

// DESPUÉS
.map((s) => s.toModel(metrics.forService(s.id).lastOrNull))
```

- [ ] **Step 12.3: Verificar que ambos archivos compilan**

```bash
flutter analyze lib/presentation/metrics/views/metrics_content_view.dart \
               lib/presentation/services/monitored_services/views/services_tab_view.dart
```

- [ ] **Step 12.4: Commit**

```bash
git add lib/presentation/metrics/views/metrics_content_view.dart \
        lib/presentation/services/monitored_services/views/services_tab_view.dart
git commit -m "feat: wire MetricsContentView with filter, bandwidth/uptime buckets, isRefreshing bar"
```

---

## Task 13: Verificación final

**Files:** Ninguno (sólo validación).

- [ ] **Step 13.1: flutter analyze limpio**

```bash
flutter analyze
```

Esperado: `No issues found!`

Si hay warnings sobre imports no usados (p.ej. `get_latest_metrics_use_case.dart`), eliminar el import del archivo correspondiente.

- [ ] **Step 13.2: Correr todos los tests**

```bash
flutter test
```

Esperado: todos los tests de `test/presentation/metrics/` pasan.

- [ ] **Step 13.3: Build web**

```bash
flutter build web
```

Esperado: compilación exitosa sin errores.

- [ ] **Step 13.4: Smoke test manual — pantalla Métricas**

```bash
flutter run
```

Verificar:
1. Pantalla Métricas carga con datos (rango `1h` por defecto).
2. El filtro `1h / 6h / 24h / 7d` cambia el rango sin blank-screen (contenido anterior visible durante recarga).
3. `LinearProgressIndicator` aparece brevemente al cambiar rango.
4. BW chart muestra dos series (Entrante y Saliente) con Y-axis compartido.
5. Uptime chart muestra ratio 0–100%, no valor > 100%.
6. Si hay buckets sin dato, el chart muestra gap en lugar de 0.
7. Dashboard no muestra ningún cambio de comportamiento.
8. Pantalla Servicios sigue mostrando las tarjetas de servicio con métricas.

- [ ] **Step 13.5: Commit final si hubo ajustes menores**

```bash
git add -p   # sólo los archivos con ajustes menores de analyze
git commit -m "fix: cleanup unused imports after metrics migration"
```
