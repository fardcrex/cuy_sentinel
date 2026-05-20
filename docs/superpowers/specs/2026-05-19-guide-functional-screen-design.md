# Guía Funcional del Panel — Pantalla `/guide`

**Fecha:** 2026-05-19
**Equipo:** Cuy Sentinel
**Scope:** Nueva pantalla `/guide` — pública, sin auth, uso interno del equipo.

---

## Contexto y objetivo

Pantalla de consulta rápida para que el equipo (Jair, Daniel, Jheampierre) pueda estudiar
y responder preguntas del profesor durante la presentación. No se muestra al profesor.
Documenta exclusivamente el comportamiento funcional de cada pantalla del panel.

Una segunda URL `/guide/technical` (fuera de scope actual) cubrirá las decisiones
de arquitectura y estará enlazada desde esta pantalla mediante un botón.

---

## Alcance

**Incluye:**
- Ruta `/guide` pública, fuera del `ShellRoute`, sin sidebar ni nav del panel.
- Header con badge de uso interno + botón "Ver guía técnica" (deshabilitado, próximamente).
- 6 tabs: Resumen · Dashboard · Servicios · Métricas · Alertas · Usuarios.
- Tab Resumen con miniaturas codificadas en Flutter + navegación a tabs.
- 5 tabs de pantalla con cards explicativas de cada widget.

**Excluye:**
- Guía técnica (`/guide/technical`) — queda pendiente para un sprint posterior.
- Integración con datos reales — todo el contenido es texto estático.
- Autenticación o restricción de acceso — la "privacidad" es por URL no publicada.

---

## Arquitectura

Pantalla estática sin Cubit ni estado complejo. Un único `StatefulWidget` (`GuidePage`)
gestiona el `TabController`. El contenido de cada tab es un `StatelessWidget` independiente.
Sin DI, sin repositorios.

```
lib/presentation/guide/
  guide_page.dart                    ← pantalla principal + TabController
  widgets/
    guide_header.dart                ← header con badge + botón técnico
    guide_tab_bar.dart               ← barra de tabs con scroll horizontal
    guide_summary_tab.dart           ← tab Resumen
    guide_screen_tab.dart            ← tab genérico por pantalla (reutilizable)
    screen_miniature/
      dashboard_miniature.dart       ← miniatura codificada del Dashboard
      services_miniature.dart        ← miniatura codificada de Servicios
      metrics_miniature.dart         ← miniatura codificada de Métricas
      alerts_miniature.dart          ← miniatura codificada de Alertas
      users_miniature.dart           ← miniatura codificada de Usuarios
```

`app_router.dart`: añadir `/guide` a `_publicRoutes` y como `GoRoute` fuera del `ShellRoute`.

---

## Componentes

### `GuidePage`

`StatefulWidget` con `SingleTickerProviderStateMixin`. Mantiene un `TabController`
de 6 tabs. Construye `Scaffold` con fondo `AppColors.background` y sin `AppBar`
estándar (usa `guide_header` + `guide_tab_bar` como cabecera personalizada).

No aplica `resizeToAvoidBottomInset: false` ni `SingleChildScrollView` con
padding de keyboard — esta pantalla no tiene formularios.

### `GuideHeader`

Fila superior fija:
- `Image.asset(AppAssets.logoHorizontalPrimary, height: 32)` + texto "Guía del Panel"
- Badge `USO INTERNO` — contenedor con fondo `AppColors.warning.withValues(alpha:0.15)`,
  borde `AppColors.warning`, texto en `AppColors.warning`, tamaño pequeño.
- Botón "Ver guía técnica →" — `OutlinedButton` deshabilitado con `Tooltip`
  "Próximamente" al mantener presionado.

### `GuideTabBar`

`TabBar` con las 6 tabs, `isScrollable: true` para mobile. Indicador de tab
usando `AppColors.primary`. Tab activa en `AppColors.primary`, inactiva en
`AppColors.textSecondary`.

### `GuideScreenTab` (widget reutilizable)

Acepta `String title`, `String description` y `List<GuideCardData> cards` donde
`GuideCardData` es un simple data class con `{IconData icon, String name, String body}`.
Cada tab de pantalla construye su lista de `GuideCardData` y la pasa a este widget.

### `GuideScreenCard` (widget reutilizable interno)

Card de explicación usada en todos los tabs de pantalla:
```
┌─────────────────────────────────────┐
│ [Ícono]  Nombre del widget          │
│          ─────────────────          │
│  Descripción de qué muestra y qué   │
│  significa cada dato o control.     │
└─────────────────────────────────────┘
```
Usa `AppCard` existente. Ícono en `AppColors.primary`. Sin interacción.

---

## Tab Resumen

Grid de 5 `SummaryScreenCard`, 2 columnas en mobile / 3 en tablet / 5 en desktop.

### `SummaryScreenCard`

Cada card tiene:
1. **Miniatura codificada** — la miniatura tiene tamaño intrínseco 180×260 y se envuelve
   en `FittedBox(fit: BoxFit.contain)` con `AspectRatio(ratio: 180/260)` para que escale
   sin overflow en cualquier ancho de columna.
2. **Nombre de la pantalla** — texto bold.
3. **2–3 bullets** — descripción de las funciones principales.
4. **Borde con color accent** por pantalla (ver tabla abajo).
5. **`onTap`** → llama `tabController.animateTo(index)` para saltar al tab correspondiente.

`GuideSummaryTab` es `StatelessWidget` y recibe `TabController tabController` como
parámetro obligatorio, pasado desde `GuidePage`.

| Pantalla   | Color accent        | Tab index |
|------------|---------------------|-----------|
| Dashboard  | `AppColors.primary` | 1         |
| Servicios  | `AppColors.secondary` | 2       |
| Métricas   | `AppColors.chartCpu` | 3        |
| Alertas    | `AppColors.warning` | 4         |
| Usuarios   | `AppColors.primaryBright` | 5   |

**Fila de chips inferior** (debajo del grid):
Chips no interactivos con los datos clave del proyecto:
`2 servicios monitoreados` · `Recolección cada 5 min` · `SNMP` · `2 fases de arquitectura` · `Passbolt · ChkMonitor`

---

## Miniaturas codificadas

Widgets Flutter de tamaño fijo (180×260) que representan la estructura visual
de cada pantalla usando formas simples (`Container`, `Row`, `Column`, `CustomPaint`).
No son pixel-perfect — capturan la disposición espacial y colores del sistema.
Fondo `AppColors.panel`, elementos internos en tonos del `AppColors` correspondiente,
con `borderRadius` y opacidades suavizadas.

### `DashboardMiniature`

Web layout (≥1100): 4 stat cards en fila → 2 columnas (flex 2 / flex 1).
```
┌────────────────────────────────────┐
│ [stat1][stat2][stat3][stat4]       │  ← 4 cards en fila
│                                    │
│ [resource chart │ [svc status   ]  │  ← col izq (flex 2) / col der (flex 1)
│ [bw chart     ] │ [collector    ]  │
│                 │ [recent events]  │
└────────────────────────────────────┘
```

### `ServicesMiniature`

La pantalla Servicios tiene dos sub-tabs internos. `ServicesMiniature` muestra ambas
vistas con un mini indicador de tabs en la parte superior para dejar claro que se alternan.
La vista activa por defecto es "Servicios".

**Vista "Servicios"** (web layout ≥900: 2 cards de servicio side by side):
```
┌────────────────────────────────────┐
│ [Servicios][Bases de datos]        │  ← mini tab indicator
│                                    │
│ [● Passbolt card][● ChkMonitor]    │  ← 2 cards side by side
│ [──── infrastructure card ──────]  │  ← full width debajo
└────────────────────────────────────┘
```

**Vista "Bases de datos"** (web layout ≥900: Supabase a la izq, Schema+PG a la der):
```
┌────────────────────────────────────┐
│ [Servicios][Bases de datos]        │  ← segunda píldora activa
│                                    │
│ [Supabase card  │ [Schema card  ]  │  ← col izq (flex 5) / col der (flex 3)
│ (flex 5)        │ [PG Primario  ]  │
│                 │ [PG Réplica   ]  │
└────────────────────────────────────┘
```

Implementación: `ServicesMiniature` es `StatefulWidget` con un `bool _showDb = false`
y un `GestureDetector` en las píldoras del tab indicator para alternar entre las dos
vistas con `AnimatedSwitcher`.

### `MetricsMiniature`

Web layout: filtros en header → 4 summary cards en fila → 2 columnas (flex 3 / flex 2).
```
┌────────────────────────────────────┐
│ [1h][6h][24h][7d] [Passbolt][Chk] │  ← filtros en header
│ [cpu][ram][disk][latency]          │  ← 4 summary cards en fila
│                                    │
│ [resource chart │ [uptime card  ]  │  ← col izq (flex 3) / col der (flex 2)
│ [bw chart     ] │ [snmp health  ]  │
└────────────────────────────────────┘
```

### `AlertsMiniature`

Web layout: badges en header → 2 columnas (flex 3 / flex 2).
```
┌────────────────────────────────────┐
│ [●crit][●warn][●total]             │  ← summary badges en header
│                                    │
│ [▌ alerts section │ [thresholds ]  │  ← col izq (flex 3) / col der (flex 2)
│ [▌ alert crítico  │ [cpu > 80%  ]  │
│ [▌ alert warning  │ [ram > 90%  ]  │
│ [▌ incidents sect]│              ] │
└────────────────────────────────────┘
```

### `UsersMiniature`

Web layout: badge en header → 2 columnas (flex 3 / flex 2).
```
┌────────────────────────────────────┐
│ [● 2 usuarios en línea]            │  ← online badge en header
│                                    │
│ [○ Admin  ••••  │ [session stats]  │  ← col izq (flex 3) / col der (flex 2)
│ [○ Viewer ••••  │ [access log   ]  │
│ [○ Admin  ••••  │                ] │
└────────────────────────────────────┘
```

---

## Contenido por tab de pantalla

### Tab Dashboard

**Descripción:** Vista principal del panel. Muestra el estado en tiempo real de ambos
servicios con métricas resumidas, gráficos de ancho de banda y últimos eventos.

| Widget | Qué muestra |
|--------|-------------|
| **Tarjetas de estado** (4 cards) | Servicios activos (online/total), Uptime promedio de todas las lecturas, Alertas activas con desglose críticas/advertencias, Total de métricas recolectadas. Cada card tiene un sparkline (mini gráfico) de la evolución reciente. |
| **Gráfico de ancho de banda** | Tráfico de red entrante y saliente en MB/s. Chips `Ambos / Passbolt / ChkMonitor` filtran qué servicio se visualiza. El gráfico se desliza de derecha a izquierda con cada nuevo dato (animación de ventana deslizante). |
| **Estado de servicios** | Tarjeta que muestra si Passbolt y ChkMonitor están online/offline en este momento, con IP, puerto SNMP y tiempo de actividad (`uptime`). |
| **Salud del recolector** | Indica si el agente Go que recolecta los datos SNMP está funcionando correctamente, cuándo fue su última ejecución y si tuvo errores. |
| **Eventos recientes** | Lista de los últimos 3 eventos del sistema: caídas, recuperaciones o degradaciones de rendimiento detectadas automáticamente. |

### Tab Servicios

**Descripción:** Detalle de los servicios monitoreados y la infraestructura de base de datos.
Tiene dos sub-tabs internos: **Servicios** y **Bases de datos**.

| Widget | Qué muestra |
|--------|-------------|
| **Sub-tab Servicios — Cards de servicio** | Una card por servicio (Passbolt, ChkMonitor). Muestra: estado actual (online/offline/degradado), IP y puerto SNMP, tiempo de uptime acumulado, versión si está disponible. |
| **Sub-tab Servicios — Card de infraestructura** | Descripción del entorno Docker donde corren los servicios: red, volúmenes, configuración general. |
| **Sub-tab Bases de datos — Supabase (Fase 1)** | Estado de la conexión a Supabase, tablas activas, URL del proyecto. Es la base de datos actual en uso. |
| **Sub-tab Bases de datos — PostgreSQL propio (Fase 2)** | Configuración del PostgreSQL self-hosted planificado para la Fase 2 del proyecto, con réplica por WAL. |
| **Sub-tab Bases de datos — Schema** | Resumen visual de las tablas del sistema: `users`, `monitored_services`, `metrics`, `service_events`, `collector_runs`. |

### Tab Métricas

**Descripción:** Histórico de métricas con filtro temporal. Permite analizar el comportamiento
de cada servicio en un rango de tiempo específico.

| Widget | Qué muestra |
|--------|-------------|
| **Fila de filtros** | Selector de servicio (`Passbolt / ChkMonitor`) y selector de rango temporal (`1h / 6h / 24h / 7d`). Al cambiar cualquier filtro se recarga el histórico correspondiente. |
| **Grid de resumen** | 4 cards con estadísticas del período seleccionado: CPU promedio (%), RAM usada (MB), Disco usado (%), Latencia SNMP (ms). Cada card muestra mínimo, promedio y máximo. |
| **Gráfico de ancho de banda** | Tráfico entrante y saliente en el período seleccionado. Muestra gaps (espacios vacíos) si no hubo datos en algún intervalo. |
| **Salud SNMP** | Latencia de respuesta SNMP y porcentaje de pérdida de paquetes en el período. Indica qué tan estable fue la comunicación con el servicio. |
| **Uptime timeline** | Línea de tiempo visual del período mostrando cuándo el servicio estuvo online (verde) y offline (rojo/vacío). |

### Tab Alertas

**Descripción:** Centro de alertas activas e historial de incidentes. Las alertas se
generan automáticamente cuando una métrica supera los umbrales configurados.

| Widget | Qué muestra |
|--------|-------------|
| **Badges de resumen** | Contadores rápidos: total de alertas activas, cuántas son críticas, cuántas son advertencias. |
| **Lista de alertas activas** | Cada alerta muestra: severidad (crítica en rojo / advertencia en ámbar), servicio afectado, métrica que la generó (ej: CPU > 80%), valor actual y tiempo desde que se activó. |
| **Sección de incidentes** | Historial de incidentes pasados: caídas o degradaciones ya resueltas, con duración y causa. |
| **Umbrales configurados** | Lista de los umbrales que disparan alertas: qué métrica, qué valor límite, qué severidad asigna. Son los parámetros de configuración del sistema de alertas. |

### Tab Usuarios

**Descripción:** Gestión de usuarios del panel. Muestra quién tiene acceso,
sus roles y su actividad reciente.

| Widget | Qué muestra |
|--------|-------------|
| **Badge de usuarios en línea** | Indicador de cuántos usuarios tienen sesión activa en este momento. |
| **Lista de usuarios** | Tabla con todos los usuarios registrados: nombre, email, rol (Admin / Viewer), estado de sesión y última actividad. |
| **Estadísticas de sesión** | Resumen de sesiones: total de logins en el período, duración promedio de sesión, horarios de mayor actividad. |
| **Log de acceso** | Historial de los últimos accesos al panel: usuario, fecha/hora, acción realizada (login, logout, cambio de contraseña). |

---

## Router

En `app_router.dart`:
1. Añadir `static const guide = '/guide'` a `AppRoutes`.
2. Añadir `/guide` al set `_publicRoutes`.
3. Añadir `GoRoute` para `/guide` **fuera** del `ShellRoute` (igual que `/login` y `/`).

```dart
GoRoute(
  path: AppRoutes.guide,
  pageBuilder: (context, state) => _buildPage(state, const GuidePage()),
),
```

---

## Notas de implementación

- Seguir el patrón `part` de `welcome_page.dart` para separar secciones grandes si un archivo supera ~200 líneas.
- Las miniaturas usan `AppColors` — no hardcodear colores.
- `GuideScreenCard` y `SummaryScreenCard` son widgets internos de `guide/` — no compartidos con el resto del panel.
- No hay navegación de vuelta al panel desde `/guide` — el usuario usa el botón back del browser/OS.
