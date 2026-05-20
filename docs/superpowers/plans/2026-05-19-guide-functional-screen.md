# Guía Funcional del Panel — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Crear la pantalla `/guide` — guía funcional interna del panel, pública (sin auth), con 6 tabs: Resumen + una tab por pantalla del panel, miniaturas codificadas en Flutter y cards explicativas de cada widget.

**Architecture:** `GuidePage` es un `StatefulWidget` que gestiona un `TabController` de 6 tabs. Todo el contenido es estático — sin Cubit, sin repositorios. Miniaturas codificadas con `Container`/`Row`/`Column`/`CustomPaint` usando `AppColors`. La ruta `/guide` se añade fuera del `ShellRoute`, en `_publicRoutes`.

**Tech Stack:** Flutter · go_router · AppColors · AppCard · AppAssets · AppBreakpoints

---

## File Map

| Archivo | Acción | Responsabilidad |
|---------|--------|-----------------|
| `lib/core/navigation/app_router.dart` | Modificar | Añadir ruta `/guide` |
| `lib/presentation/guide/guide_page.dart` | Crear | Scaffold + TabController + contenido de los 5 tabs de pantalla |
| `lib/presentation/guide/widgets/guide_header.dart` | Crear | Header con logo, badge USO INTERNO, botón técnico deshabilitado |
| `lib/presentation/guide/widgets/guide_tab_bar.dart` | Crear | TabBar scrolleable con 6 tabs |
| `lib/presentation/guide/widgets/guide_screen_tab.dart` | Crear | `GuideCardData`, `GuideScreenTab`, `_GuideScreenCard`, `_CardGrid` |
| `lib/presentation/guide/widgets/guide_summary_tab.dart` | Crear | Tab Resumen con grid de 5 `SummaryScreenCard` + chips |
| `lib/presentation/guide/widgets/screen_miniature/mini_shared.dart` | Crear | Helpers compartidos: `_MiniBox`, `_MiniChartBox`, `_LinePainter` |
| `lib/presentation/guide/widgets/screen_miniature/dashboard_miniature.dart` | Crear | Miniatura del Dashboard (web layout) |
| `lib/presentation/guide/widgets/screen_miniature/services_miniature.dart` | Crear | Miniatura de Servicios (StatefulWidget con 2 vistas) |
| `lib/presentation/guide/widgets/screen_miniature/metrics_miniature.dart` | Crear | Miniatura de Métricas (web layout) |
| `lib/presentation/guide/widgets/screen_miniature/alerts_miniature.dart` | Crear | Miniatura de Alertas (web layout) |
| `lib/presentation/guide/widgets/screen_miniature/users_miniature.dart` | Crear | Miniatura de Usuarios (web layout) |

---

## Task 1: Router — añadir ruta `/guide`

**Files:**
- Modify: `lib/core/navigation/app_router.dart`

- [ ] **Step 1: Añadir la constante de ruta y el import**

```dart
// En app_router.dart — añadir import al top:
import '../../presentation/guide/guide_page.dart';

// En AppRoutes — añadir:
static const guide = '/guide';

// _publicRoutes — cambiar a:
const _publicRoutes = {AppRoutes.welcome, AppRoutes.login, AppRoutes.guide};

// Dentro de createAppRouter, ANTES del ShellRoute, añadir:
GoRoute(
  path: AppRoutes.guide,
  pageBuilder: (context, state) => _buildPage(state, const GuidePage()),
),
```

El bloque `routes: [...]` en `createAppRouter` queda así:
```dart
routes: [
  GoRoute(
    path: AppRoutes.login,
    pageBuilder: (context, state) => _buildPage(state, const LoginPage()),
  ),
  GoRoute(
    path: AppRoutes.welcome,
    pageBuilder: (context, state) => _buildPage(state, const WelcomePage()),
  ),
  GoRoute(
    path: AppRoutes.guide,
    pageBuilder: (context, state) => _buildPage(state, const GuidePage()),
  ),
  ShellRoute(
    builder: (context, state, child) =>
        ResponsiveShell(currentPath: state.matchedLocation, child: child),
    routes: [ /* sin cambios */ ],
  ),
],
```

- [ ] **Step 2: Verificar que no hay errores de import** (el archivo `guide_page.dart` aún no existe — `flutter analyze` fallará hasta el Task 11, ignorar por ahora)

---

## Task 2: `GuideHeader`

**Files:**
- Create: `lib/presentation/guide/widgets/guide_header.dart`

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class GuideHeader extends StatelessWidget {
  const GuideHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.stroke)),
      ),
      child: Row(
        children: [
          Image.asset(AppAssets.logoHorizontalPrimary, height: 32),
          const SizedBox(width: 12),
          Text(
            'Guía del Panel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
              ),
            ),
            child: const Text(
              'USO INTERNO',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Spacer(),
          Tooltip(
            message: 'Próximamente',
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.science_outlined, size: 15),
              label: const Text('Ver guía técnica →'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textInactive,
                side: const BorderSide(color: AppColors.stroke),
                textStyle: const TextStyle(fontSize: 13),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Task 3: `GuideTabBar`

**Files:**
- Create: `lib/presentation/guide/widgets/guide_tab_bar.dart`

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class GuideTabBar extends StatelessWidget {
  const GuideTabBar({super.key, required this.controller});

  final TabController controller;

  static const _labels = [
    'Resumen',
    'Dashboard',
    'Servicios',
    'Métricas',
    'Alertas',
    'Usuarios',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panel,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        tabs: _labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }
}
```

---

## Task 4: `GuideScreenTab`, `GuideCardData`, `_GuideScreenCard`

**Files:**
- Create: `lib/presentation/guide/widgets/guide_screen_tab.dart`

Este archivo contiene el data class, el card individual y el widget de tab genérico reutilizable para todos los 5 tabs de pantalla.

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';

class GuideCardData {
  const GuideCardData({
    required this.icon,
    required this.name,
    required this.body,
  });

  final IconData icon;
  final String name;
  final String body;
}

class GuideScreenTab extends StatelessWidget {
  const GuideScreenTab({
    super.key,
    required this.title,
    required this.description,
    required this.cards,
  });

  final String title;
  final String description;
  final List<GuideCardData> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final columns = width >= 900 ? 2 : 1;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _CardGrid(cards: cards, columns: columns),
            ],
          ),
        );
      },
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.cards, required this.columns});

  final List<GuideCardData> cards;
  final int columns;

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _GuideScreenCard(data: cards[i]),
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _GuideScreenCard(data: cards[i])),
            const SizedBox(width: 16),
            Expanded(
              child: i + 1 < cards.length
                  ? _GuideScreenCard(data: cards[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _GuideScreenCard extends StatelessWidget {
  const _GuideScreenCard({required this.data});

  final GuideCardData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Divider(color: AppColors.stroke, height: 1),
                const SizedBox(height: 8),
                Text(
                  data.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Task 5: `mini_shared.dart` — helpers compartidos para miniaturas

**Files:**
- Create: `lib/presentation/guide/widgets/screen_miniature/mini_shared.dart`

Contiene `_MiniBox` (caja gris genérica) y `_MiniChartBox` con `_LinePainter` (caja con línea zigzag animada usada en Dashboard y Métricas). Todos son privados al folder.

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MiniBox extends StatelessWidget {
  const MiniBox({super.key, this.accentColor, this.height});

  final Color? accentColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: accentColor?.withValues(alpha: 0.35) ?? AppColors.stroke,
        ),
      ),
    );
  }
}

class MiniChartBox extends StatelessWidget {
  const MiniChartBox({super.key, required this.color, this.points});

  final Color color;
  final List<double>? points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: MiniLinePainter(color: color, points: points),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class MiniLinePainter extends CustomPainter {
  const MiniLinePainter({required this.color, this.points});

  final Color color;
  final List<double>? points;

  static const _defaultPoints = [
    0.0, 0.55,
    0.15, 0.75,
    0.30, 0.40,
    0.45, 0.65,
    0.60, 0.30,
    0.75, 0.55,
    0.90, 0.25,
    1.0, 0.45,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final pts = points ?? _defaultPoints;
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < pts.length; i += 2) {
      final x = pts[i] * size.width;
      final y = size.height - pts[i + 1] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = color.withValues(alpha: 0.07),
    );
  }

  @override
  bool shouldRepaint(covariant MiniLinePainter old) =>
      old.color != color || old.points != points;
}

class MiniTabPill extends StatelessWidget {
  const MiniTabPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
```

---

## Task 6: `DashboardMiniature`

**Files:**
- Create: `lib/presentation/guide/widgets/screen_miniature/dashboard_miniature.dart`

Layout web: 4 stat cards en fila → 2 columnas (flex 2 / flex 1).

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class DashboardMiniature extends StatelessWidget {
  const DashboardMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // 4 stat cards en fila
          Row(
            children: [
              _StatCard(color: AppColors.primary),
              const SizedBox(width: 3),
              _StatCard(color: AppColors.primaryBright),
              const SizedBox(width: 3),
              _StatCard(color: AppColors.warning),
              const SizedBox(width: 3),
              _StatCard(color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 5),
          // 2 columnas: flex 2 (charts) / flex 1 (sidebar)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniChartBox(color: AppColors.chartCpu),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: MiniChartBox(
                          color: AppColors.chartNetwork,
                          points: const [
                            0.0, 0.4, 0.2, 0.65, 0.35, 0.5,
                            0.55, 0.8, 0.7, 0.45, 0.85, 0.7, 1.0, 0.55,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: MiniBox(accentColor: AppColors.primary)),
                      const SizedBox(height: 3),
                      Expanded(child: const MiniBox()),
                      const SizedBox(height: 3),
                      Expanded(child: const MiniBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Task 7: `ServicesMiniature`

**Files:**
- Create: `lib/presentation/guide/widgets/screen_miniature/services_miniature.dart`

`StatefulWidget` con dos vistas alternables (Servicios / Bases de datos) usando `AnimatedSwitcher`.

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class ServicesMiniature extends StatefulWidget {
  const ServicesMiniature({super.key});

  @override
  State<ServicesMiniature> createState() => _ServicesMiniatureState();
}

class _ServicesMiniatureState extends State<ServicesMiniature> {
  bool _showDb = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini tab indicator
          Row(
            children: [
              MiniTabPill(
                label: 'Servicios',
                active: !_showDb,
                onTap: () => setState(() => _showDb = false),
              ),
              const SizedBox(width: 4),
              MiniTabPill(
                label: 'BD',
                active: _showDb,
                onTap: () => setState(() => _showDb = true),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showDb
                  ? const _DbView(key: ValueKey('db'))
                  : const _ServicesView(key: ValueKey('svc')),
            ),
          ),
        ],
      ),
    );
  }
}

// Vista "Servicios": 2 service cards side by side + infrastructure card abajo
class _ServicesView extends StatelessWidget {
  const _ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _ServiceCard(color: AppColors.primary)),
              const SizedBox(width: 4),
              Expanded(child: _ServiceCard(color: AppColors.secondary)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.stroke),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 3,
                height: double.infinity,
                color: AppColors.textInactive.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 5),
              Container(
                width: 40,
                height: 3,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 3,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.stroke,
          ),
          const SizedBox(height: 5),
          Container(
            width: 30,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 3),
          Container(
            width: 22,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 3),
          Container(
            width: 26,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// Vista "Bases de datos": Supabase (flex 5) + Schema/PG cards (flex 3)
class _DbView extends StatelessWidget {
  const _DbView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                for (var i = 0; i < 4; i++) ...[
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(
                child: MiniBox(accentColor: AppColors.secondary),
              ),
              const SizedBox(height: 3),
              Expanded(child: const MiniBox()),
              const SizedBox(height: 3),
              Expanded(child: const MiniBox()),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## Task 8: `MetricsMiniature`

**Files:**
- Create: `lib/presentation/guide/widgets/screen_miniature/metrics_miniature.dart`

Layout web: filtros en header → 4 summary cards → 2 columnas (flex 3 / flex 2).

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class MetricsMiniature extends StatelessWidget {
  const MetricsMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Filter chips: time + service
          Row(
            children: [
              for (final t in ['1h', '6h', '24h', '7d'])
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: _FilterChip(label: t, active: t == '1h'),
                ),
              const Spacer(),
              _FilterChip(label: 'PB', active: false),
            ],
          ),
          const SizedBox(height: 4),
          // 4 summary cards en fila
          Row(
            children: [
              _SummaryCard(color: AppColors.chartCpu),
              const SizedBox(width: 2),
              _SummaryCard(color: AppColors.chartRam),
              const SizedBox(width: 2),
              _SummaryCard(color: AppColors.chartDisk),
              const SizedBox(width: 2),
              _SummaryCard(color: AppColors.chartNetwork),
            ],
          ),
          const SizedBox(height: 4),
          // 2 columnas: flex 3 (charts) / flex 2 (uptime + snmp)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniChartBox(
                          color: AppColors.chartCpu,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: MiniChartBox(
                          color: AppColors.chartNetwork,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: _UptimeBox(),
                      ),
                      const SizedBox(height: 3),
                      Expanded(child: const MiniBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.stroke,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          color: active ? AppColors.primary : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 2,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _UptimeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              for (var i = 0; i < 8; i++) ...[
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 3
                          ? AppColors.danger.withValues(alpha: 0.6)
                          : AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                if (i < 7) const SizedBox(width: 1),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Task 9: `AlertsMiniature`

**Files:**
- Create: `lib/presentation/guide/widgets/screen_miniature/alerts_miniature.dart`

Layout web: badges en header → 2 columnas (flex 3 / flex 2).

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class AlertsMiniature extends StatelessWidget {
  const AlertsMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary badges row
          Row(
            children: [
              _Badge(color: AppColors.danger, label: '●2'),
              const SizedBox(width: 4),
              _Badge(color: AppColors.warning, label: '●3'),
              const SizedBox(width: 4),
              _Badge(color: AppColors.textSecondary, label: '5'),
            ],
          ),
          const SizedBox(height: 5),
          // 2 columnas: flex 3 (alerts+incidents) / flex 2 (thresholds)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _AlertItem(color: AppColors.danger),
                      const SizedBox(height: 3),
                      _AlertItem(color: AppColors.warning),
                      const SizedBox(height: 3),
                      _AlertItem(color: AppColors.warning),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: AppColors.stroke,
                      ),
                      const SizedBox(height: 4),
                      _AlertItem(color: AppColors.textInactive),
                      const SizedBox(height: 3),
                      _AlertItem(color: AppColors.textInactive),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _ThresholdRow(),
                      const SizedBox(height: 3),
                      _ThresholdRow(),
                      const SizedBox(height: 3),
                      _ThresholdRow(),
                      const SizedBox(height: 3),
                      _ThresholdRow(),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
        border: Border(
          left: BorderSide(color: color, width: 2),
          top: BorderSide(color: AppColors.stroke),
          right: BorderSide(color: AppColors.stroke),
          bottom: BorderSide(color: AppColors.stroke),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 3),
          Container(
            width: 10,
            height: 2,
            color: AppColors.warning.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
```

---

## Task 10: `UsersMiniature`

**Files:**
- Create: `lib/presentation/guide/widgets/screen_miniature/users_miniature.dart`

Layout web: badge en header → 2 columnas (flex 3 / flex 2).

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class UsersMiniature extends StatelessWidget {
  const UsersMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Online badge en header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '2 online',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // 2 columnas: flex 3 (users list) / flex 2 (stats + log)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _UserRow(color: AppColors.primary),
                      const SizedBox(height: 4),
                      _UserRow(color: AppColors.textSecondary),
                      const SizedBox(height: 4),
                      _UserRow(color: AppColors.primary),
                      const SizedBox(height: 4),
                      _UserRow(color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniBox(accentColor: AppColors.primaryBright),
                      ),
                      const SizedBox(height: 4),
                      Expanded(child: const MiniBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 2,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 3),
              Container(
                width: 24,
                height: 2,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## Task 11: `GuideSummaryTab`

**Files:**
- Create: `lib/presentation/guide/widgets/guide_summary_tab.dart`

Grid de 5 `SummaryScreenCard` + fila de chips de datos clave. Recibe `TabController` para navegar al tab al tocar una card.

- [ ] **Step 1: Crear el widget**

```dart
import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'screen_miniature/dashboard_miniature.dart';
import 'screen_miniature/services_miniature.dart';
import 'screen_miniature/metrics_miniature.dart';
import 'screen_miniature/alerts_miniature.dart';
import 'screen_miniature/users_miniature.dart';

class GuideSummaryTab extends StatelessWidget {
  const GuideSummaryTab({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final columns = AppBreakpoints.isDesktop(width)
            ? 5
            : AppBreakpoints.isTablet(width)
                ? 3
                : 2;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Cuy Sentinel',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Guía funcional de cada sección. Toca una card para ir al detalle.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _SummaryGrid(
                tabController: tabController,
                columns: columns,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _InfoChip(label: '2 servicios monitoreados'),
                  _InfoChip(label: 'Recolección cada 5 min'),
                  _InfoChip(label: 'SNMP'),
                  _InfoChip(label: '2 fases de arquitectura'),
                  _InfoChip(label: 'Passbolt · ChkMonitor'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.tabController,
    required this.columns,
  });

  final TabController tabController;
  final int columns;

  static final _cards = [
    _SummaryCardData(
      miniature: const DashboardMiniature(),
      name: 'Dashboard',
      bullets: [
        '4 tarjetas de estado en tiempo real',
        'Gráficos de recursos y ancho de banda',
        'Últimos eventos del sistema',
      ],
      accentColor: AppColors.primary,
      tabIndex: 1,
    ),
    _SummaryCardData(
      miniature: const ServicesMiniature(),
      name: 'Servicios',
      bullets: [
        'Estado de Passbolt y ChkMonitor',
        'Infraestructura Docker',
        '2 vistas: Servicios y Bases de datos',
      ],
      accentColor: AppColors.secondary,
      tabIndex: 2,
    ),
    _SummaryCardData(
      miniature: const MetricsMiniature(),
      name: 'Métricas',
      bullets: [
        'Histórico por rango (1h / 6h / 24h / 7d)',
        'CPU, RAM, Disco, Latencia SNMP',
        'Timeline de uptime',
      ],
      accentColor: AppColors.chartCpu,
      tabIndex: 3,
    ),
    _SummaryCardData(
      miniature: const AlertsMiniature(),
      name: 'Alertas',
      bullets: [
        'Alertas activas por severidad',
        'Historial de incidentes',
        'Umbrales configurados',
      ],
      accentColor: AppColors.warning,
      tabIndex: 4,
    ),
    _SummaryCardData(
      miniature: const UsersMiniature(),
      name: 'Usuarios',
      bullets: [
        'Lista de usuarios y roles',
        'Sesiones activas en tiempo real',
        'Log de accesos recientes',
      ],
      accentColor: AppColors.primaryBright,
      tabIndex: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (columns >= 5) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              child: _SummaryScreenCard(
                data: _cards[i],
                onTap: () => tabController.animateTo(_cards[i].tabIndex),
              ),
            ),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < _cards.length; i += columns) {
      final rowCards = _cards.skip(i).take(columns).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < columns; j++) ...[
              if (j > 0) const SizedBox(width: 16),
              Expanded(
                child: j < rowCards.length
                    ? _SummaryScreenCard(
                        data: rowCards[j],
                        onTap: () =>
                            tabController.animateTo(rowCards[j].tabIndex),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      if (i + columns < _cards.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.miniature,
    required this.name,
    required this.bullets,
    required this.accentColor,
    required this.tabIndex,
  });

  final Widget miniature;
  final String name;
  final List<String> bullets;
  final Color accentColor;
  final int tabIndex;
}

class _SummaryScreenCard extends StatelessWidget {
  const _SummaryScreenCard({required this.data, required this.onTap});

  final _SummaryCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: data.accentColor.withValues(alpha: 0.35)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura escalada
            AspectRatio(
              aspectRatio: 180 / 260,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: data.miniature,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final bullet in data.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '· ',
                      style: TextStyle(
                        color: data.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
```

---

## Task 12: `GuidePage` — ensamblaje final

**Files:**
- Create: `lib/presentation/guide/guide_page.dart`

Ensambla todos los widgets anteriores. Define el contenido de los 5 tabs de pantalla (`GuideCardData` lists) inline.

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/guide_header.dart';
import 'widgets/guide_screen_tab.dart';
import 'widgets/guide_summary_tab.dart';
import 'widgets/guide_tab_bar.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GuideHeader(),
          GuideTabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GuideSummaryTab(tabController: _tabController),
                _dashboardTab(),
                _serviciosTab(),
                _metricasTab(),
                _alertasTab(),
                _usuariosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardTab() => const GuideScreenTab(
    title: 'Dashboard',
    description:
        'Vista principal del panel. Muestra el estado en tiempo real de ambos servicios con métricas resumidas, gráficos de rendimiento y últimos eventos del sistema.',
    cards: [
      GuideCardData(
        icon: Icons.grid_view_rounded,
        name: 'Tarjetas de estado (4 cards)',
        body:
            'Fila superior con un resumen rápido del sistema:\n'
            '• Servicios activos: cuántos de los 2 servicios están online ahora.\n'
            '• Uptime promedio: porcentaje de tiempo online calculado sobre todas las lecturas recibidas.\n'
            '• Alertas activas: total de alertas con desglose entre críticas y advertencias.\n'
            '• Métricas recolectadas: total acumulado de lecturas.\n'
            'Cada card tiene un sparkline (mini gráfico) que muestra la tendencia reciente.',
      ),
      GuideCardData(
        icon: Icons.memory_rounded,
        name: 'Gráfico de recursos (CPU, RAM, Disco)',
        body:
            'Gráfico de líneas con el historial de CPU (%), RAM (MB) y Disco (%) de ambos servicios. '
            'Cada métrica tiene su propio color. Permite ver picos de consumo recientes '
            'sin necesidad de ir a la pantalla de Métricas.',
      ),
      GuideCardData(
        icon: Icons.network_check_rounded,
        name: 'Gráfico de ancho de banda',
        body:
            'Muestra el tráfico de red entrante y saliente en MB/s. '
            'Los chips Ambos / Passbolt / ChkMonitor filtran qué servicio se visualiza. '
            'El gráfico se desliza de derecha a izquierda con cada nuevo dato recibido '
            '(animación de ventana deslizante cada 5 segundos).',
      ),
      GuideCardData(
        icon: Icons.cloud_done_rounded,
        name: 'Estado de servicios',
        body:
            'Card que muestra si Passbolt y ChkMonitor están online, offline o degradados '
            'en este momento. Incluye IP, puerto SNMP y tiempo de actividad acumulado (uptime) '
            'de cada servicio.',
      ),
      GuideCardData(
        icon: Icons.health_and_safety_outlined,
        name: 'Salud del recolector',
        body:
            'Indica si el agente Go que recolecta los datos SNMP está funcionando correctamente. '
            'Muestra cuándo fue su última ejecución, cuánto tardó y si tuvo errores. '
            'Si falla, los datos dejan de actualizarse aunque los servicios estén online.',
      ),
      GuideCardData(
        icon: Icons.timeline_rounded,
        name: 'Eventos recientes',
        body:
            'Lista de los últimos 3 eventos del sistema: caídas detectadas, recuperaciones '
            'y degradaciones de rendimiento. Cada evento muestra el servicio afectado, '
            'la fecha/hora y una descripción breve de lo ocurrido.',
      ),
    ],
  );

  Widget _serviciosTab() => const GuideScreenTab(
    title: 'Servicios',
    description:
        'Detalle de los servicios monitoreados y la infraestructura de base de datos. '
        'Se divide en dos sub-tabs: Servicios y Bases de datos.',
    cards: [
      GuideCardData(
        icon: Icons.dns_rounded,
        name: 'Sub-tab Servicios — Cards de servicio',
        body:
            'Una card por servicio monitoreado (Passbolt y ChkMonitor) mostradas side by side. '
            'Cada card muestra: estado actual (online / offline / degradado), '
            'IP y puerto SNMP, tiempo de uptime acumulado y versión si está disponible. '
            'Los dos servicios aparecen en paralelo para comparación directa.',
      ),
      GuideCardData(
        icon: Icons.storage_rounded,
        name: 'Sub-tab Servicios — Card de infraestructura',
        body:
            'Descripción del entorno Docker donde corren los servicios: '
            'configuración de red, volúmenes montados y estructura general de contenedores. '
            'Aparece debajo de las cards de servicio, a ancho completo.',
      ),
      GuideCardData(
        icon: Icons.cloud_outlined,
        name: 'Sub-tab Bases de datos — Supabase (Fase 1)',
        body:
            'Card principal (izquierda, mayor tamaño) con el estado de la conexión a Supabase: '
            'tablas activas, URL del proyecto y estado del servicio. '
            'Es la base de datos actualmente en uso en Fase 1. '
            'Marcada con la píldora "1 activa".',
      ),
      GuideCardData(
        icon: Icons.table_chart_outlined,
        name: 'Sub-tab Bases de datos — Schema',
        body:
            'Resumen visual de las tablas del sistema: users, monitored_services, metrics, '
            'service_events y collector_runs. Muestra las relaciones principales y '
            'el propósito de cada tabla.',
      ),
      GuideCardData(
        icon: Icons.storage_outlined,
        name: 'Sub-tab Bases de datos — PostgreSQL Fase 2',
        body:
            'Dos cards (derecha): PostgreSQL Primario y Réplica streaming. '
            'Son la base de datos planificada para Fase 2: auto-hospedada en Ubuntu 24.04, '
            'con réplica asíncrona WAL para alta disponibilidad. '
            'Marcadas con la píldora "2 en Fase 2".',
      ),
    ],
  );

  Widget _metricasTab() => const GuideScreenTab(
    title: 'Métricas',
    description:
        'Histórico de métricas con filtro temporal. Permite analizar el comportamiento '
        'de cada servicio en un rango de tiempo específico, con gráficos y estadísticas agregadas.',
    cards: [
      GuideCardData(
        icon: Icons.tune_rounded,
        name: 'Fila de filtros',
        body:
            'Controles en el header de la pantalla:\n'
            '• Selector de servicio: Passbolt o ChkMonitor (uno a la vez).\n'
            '• Selector de rango temporal: 1h, 6h, 24h, 7d.\n'
            'Al cambiar cualquier filtro, todos los gráficos y estadísticas se recargan '
            'con datos del nuevo rango. Durante la carga aparece una barra de progreso delgada.',
      ),
      GuideCardData(
        icon: Icons.grid_view_rounded,
        name: 'Grid de resumen',
        body:
            'Cuatro cards con estadísticas agregadas del período seleccionado: '
            'CPU (%), RAM (MB), Disco (%) y Latencia SNMP (ms). '
            'Cada card muestra el mínimo, promedio y máximo del período. '
            'El servicio mostrado depende del filtro seleccionado.',
      ),
      GuideCardData(
        icon: Icons.memory_rounded,
        name: 'Gráfico de recursos (histórico)',
        body:
            'Gráfico de líneas multi-serie con el historial de CPU, RAM y Disco '
            'en el rango seleccionado. Muestra gaps (espacios vacíos) si no hubo '
            'datos en algún intervalo de tiempo.',
      ),
      GuideCardData(
        icon: Icons.show_chart_rounded,
        name: 'Gráfico de ancho de banda (histórico)',
        body:
            'Tráfico entrante y saliente en MB/s para el servicio y rango seleccionados. '
            'A diferencia del dashboard (tiempo real), aquí los datos son históricos '
            'agrupados en buckets de tiempo.',
      ),
      GuideCardData(
        icon: Icons.schedule_rounded,
        name: 'Uptime timeline',
        body:
            'Línea de tiempo visual del período mostrando cuándo el servicio estuvo online '
            '(verde) y offline o sin datos (rojo / vacío). '
            'Permite ver de un vistazo los períodos de caída en el rango analizado.',
      ),
      GuideCardData(
        icon: Icons.wifi_tethering_rounded,
        name: 'Salud SNMP',
        body:
            'Latencia de respuesta SNMP en ms y porcentaje de pérdida de paquetes '
            'en el período seleccionado. Indica qué tan estable fue la comunicación '
            'SNMP con el servicio — valores altos indican problemas de red o sobrecarga.',
      ),
    ],
  );

  Widget _alertasTab() => const GuideScreenTab(
    title: 'Alertas',
    description:
        'Centro de alertas activas e historial de incidentes. Las alertas se generan '
        'automáticamente cuando una métrica SNMP supera los umbrales configurados.',
    cards: [
      GuideCardData(
        icon: Icons.summarize_outlined,
        name: 'Badges de resumen',
        body:
            'Tres contadores en el header: total de alertas activas, cuántas son críticas '
            '(rojo) y cuántas son advertencias (ámbar). '
            'Permiten ver el estado global de alertas de un vistazo sin necesidad de leer la lista.',
      ),
      GuideCardData(
        icon: Icons.notifications_active_rounded,
        name: 'Lista de alertas activas',
        body:
            'Cada alerta muestra: severidad indicada por el color del borde izquierdo '
            '(rojo = crítico, ámbar = advertencia), servicio afectado, '
            'métrica que la generó (ej: CPU > 80%), valor actual y '
            'tiempo transcurrido desde que se activó.',
      ),
      GuideCardData(
        icon: Icons.history_rounded,
        name: 'Sección de incidentes',
        body:
            'Historial de incidentes ya resueltos: caídas de servicios o períodos de '
            'degradación que ya terminaron. Cada incidente muestra la causa, '
            'cuánto duró y cuándo se resolvió.',
      ),
      GuideCardData(
        icon: Icons.rule_rounded,
        name: 'Umbrales configurados',
        body:
            'Panel lateral (derecha en desktop) con la lista de umbrales que disparan alertas: '
            'qué métrica se monitorea, qué valor límite la activa y '
            'qué severidad se asigna al superarlo. '
            'Son los parámetros del sistema de alertas automáticas.',
      ),
    ],
  );

  Widget _usuariosTab() => const GuideScreenTab(
    title: 'Usuarios',
    description:
        'Gestión de usuarios del panel. Muestra quién tiene acceso al sistema, '
        'sus roles asignados y su actividad reciente de sesión.',
    cards: [
      GuideCardData(
        icon: Icons.people_outline_rounded,
        name: 'Badge de usuarios en línea',
        body:
            'Indicador en el header que muestra cuántos usuarios tienen una sesión activa '
            'en el panel en este momento.',
      ),
      GuideCardData(
        icon: Icons.manage_accounts_outlined,
        name: 'Lista de usuarios',
        body:
            'Tabla principal (izquierda en desktop) con todos los usuarios registrados: '
            'nombre, email, rol (Admin o Viewer), estado de sesión actual '
            'y fecha/hora de última actividad.',
      ),
      GuideCardData(
        icon: Icons.analytics_outlined,
        name: 'Estadísticas de sesión',
        body:
            'Resumen de actividad: total de logins en el período, '
            'duración promedio de sesión y horarios de mayor actividad. '
            'Aparece en la columna derecha en desktop.',
      ),
      GuideCardData(
        icon: Icons.fact_check_outlined,
        name: 'Log de acceso',
        body:
            'Historial de los últimos accesos al panel: '
            'qué usuario entró, cuándo y qué acción realizó '
            '(login, logout, cambio de contraseña). '
            'Aparece debajo de estadísticas de sesión en desktop.',
      ),
    ],
  );
}
```

---

## Task 13: Verificar y commit

**Files:**
- (ninguno nuevo)

- [ ] **Step 1: Correr `flutter analyze`**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel
flutter analyze
```

Resultado esperado: sin errores. Si hay warnings de `withValues` o imports faltantes, corregirlos antes de continuar.

- [ ] **Step 2: Correr la app y navegar a `/guide`**

```bash
flutter run -d chrome
```

En el browser, ir a `localhost:<puerto>/guide`. Verificar:
- Header visible con badge "USO INTERNO" y botón técnico deshabilitado
- 6 tabs visibles y scrolleables
- Tab Resumen: 5 cards con miniaturas, chips de info abajo
- Tocar cada card del Resumen → navega al tab correcto
- En `ServicesMiniature`: tocar "BD" → cambia a vista de bases de datos
- Cada tab de pantalla: título, descripción y cards explicativas correctos
- Sin overflow ni errores en consola

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/guide/ lib/core/navigation/app_router.dart
git commit -m "feat: add /guide internal functional reference screen

Internal-only screen at /guide (no auth required, not linked in nav).
6 tabs: Summary + one per panel screen. Each summary card has a coded
Flutter miniature reflecting the real web layout + bullet descriptions.
Screen tabs explain each widget with icon + name + body."
```
