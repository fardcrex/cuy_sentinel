# CLAUDE.md — Cuy Sentinel

Panel de monitoreo externo para infraestructura dockerizada (Passbolt + ChkMonitor) vía SNMP.
Proyecto universitario — Programación de Interfaces y Dispositivos Periféricos.
Prof. Rene Alejandro Zamudio Ariza.

Equipo: Jair Conislla Bocangel · Daniel Rojas Sanchez · Jheampierre Ralli Peralta.

---

## Filosofía de ingeniería

Este proyecto es universitario en contexto pero **no en estándares**. El objetivo
es aprender las formas correctas de la industria, no simplificar porque "es de U".

- Si hay una solución más correcta que la que Jair propone → implementarla completa
- "Sobreingeniería" está justificada cuando representa buenas prácticas reales
- Sealed classes > nullables semánticos. Tipos explícitos > convenciones implícitas
- Nunca simplificar por contexto académico — traer siempre el estándar industrial
- El objetivo es estar preparados para trabajo profesional, usando este proyecto
  como campo de práctica real

---

## Stack

| Área             | Tecnología                                  |
| ---------------- | ------------------------------------------- |
| Panel (frontend) | Flutter multiplataforma                     |
| Routing          | go_router con ShellRoute                    |
| Recolector       | Go (backend_go/) — fase 2                   |
| BD Fase 1        | Supabase (PostgreSQL cloud)                 |
| BD Fase 2        | PostgreSQL propio con réplica streaming/WAL |
| API Fase 2       | Node.js + Socket.IO                         |
| SNMP             | Passbolt :1161 · ChkMonitor :2161           |
| SO despliegue    | Ubuntu 24.04 LTS                            |

---

## Arquitectura en dos fases

### Fase 1 — rápida (Supabase)

```
Flutter → Supabase (REST + Realtime)
Go recolector → SNMP → Supabase
```

### Fase 2 — escalable (self-hosted)

```
Flutter → Node.js API + Socket.IO
Go recolector → SNMP → PostgreSQL primario
PostgreSQL primario → réplica asíncrona (WAL)
```

El patrón de interfaces (`IMonitoringRepository`, `IAuthRepository`) permite cambiar
de Supabase a PostgreSQL propio sin alterar la lógica del panel.

---

## Estructura de carpetas

```
Projects/
├── cuy_sentinel/           # ← este repo — panel Flutter
│   ├── envs/
│   │   ├── sentinel.example.json   # plantilla (se versiona)
│   │   ├── sentinel.phase1.json    # Supabase (NO se versiona)
│   │   └── sentinel.phase2.json    # PostgreSQL/API (NO se versiona)
│   └── lib/
│       ├── core/           # env · services/interfaces  # assets · navigation · responsive · theme
│       ├── feature/        # auth/domain · monitoring/domain
│       └── presentation/   # pages · widgets
│
└── cuy_sentinel_go/        # recolector SNMP en Go
    ├── database/
    │   └── schema.sql      # DDL: users · monitored_services · metrics
    ├── internal/
    │   ├── collector/      # interfaz Collector + tipos Metrics
    │   └── storage/        # interfaz Storage (Supabase ↔ PostgreSQL)
    ├── go.mod
    └── main.go
```

---

## Rutas (go_router)

| Constante             | Path         | Shell |
| --------------------- | ------------ | ----- |
| `AppRoutes.login`     | `/login`     | No    |
| `AppRoutes.welcome`   | `/`          | No    |
| `AppRoutes.dashboard` | `/dashboard` | Sí    |
| `AppRoutes.services`  | `/services`  | Sí    |
| `AppRoutes.metrics`   | `/metrics`   | Sí    |
| `AppRoutes.alerts`    | `/alerts`    | Sí    |
| `AppRoutes.users`     | `/users`     | Sí    |

Navegar: `context.go(AppRoutes.dashboard)` — nunca usar `Navigator` directamente.

---

## Base de datos

```sql
users              -- auth (Supabase Fase 1 / propia Fase 2) + session_expires_at
user_access_logs   -- registro de login/logout por usuario
monitored_services -- Passbolt y ChkMonitor registrados
metrics            -- CPU%, RAM, disco%, BW, uptime, status, latencia SNMP · cada 5 min
service_events     -- historial de caídas, recuperaciones y degradaciones
alert_thresholds   -- umbrales que disparan alertas (CPU, RAM, disco, latencia)
alert_events       -- alertas disparadas cuando una métrica supera un umbral
collector_runs     -- automonitoreo del agente Go (éxito/fallo, duración, versión)
```

Ver `cuy_sentinel_go/database/schema.sql` para DDL completo con índices y políticas RLS.

### ⚠️ Configuración obligatoria en Supabase (Fase 1)

El `schema.sql` incluye el bloque de **Row Level Security** que debe ejecutarse en el
SQL Editor del dashboard de Supabase antes de usar el panel. Sin él, ninguna operación
del panel Flutter funcionará (Supabase deniega todo por defecto cuando RLS está activo).

Resumen de lo que configura:

| Tabla              | Panel Flutter         | Colector Go (service_role) |
| ------------------ | --------------------- | -------------------------- |
| `users`            | SELECT + UPDATE propio | —                         |
| `user_access_logs` | INSERT propio + SELECT | —                         |
| `monitored_services` | SELECT             | INSERT/UPDATE             |
| `metrics`          | SELECT                | INSERT                     |
| `service_events`   | SELECT                | INSERT/UPDATE              |
| `alert_thresholds` | SELECT                | INSERT/UPDATE              |
| `alert_events`     | SELECT + UPDATE (resolver) | INSERT                |
| `collector_runs`   | SELECT                | INSERT/UPDATE              |

> El colector usa `service_role` (clave secreta) → bypasea RLS automáticamente,
> no necesita políticas propias.

---

## Variables de entorno

Las credenciales se pasan en tiempo de compilación con `--dart-define-from-file`.

```sh
# Copiar la plantilla y rellenar
cp envs/sentinel.example.json envs/sentinel.phase1.json
# Editar con URL y anon key de Supabase
```

| Variable            | Descripción                                   |
| ------------------- | --------------------------------------------- |
| `SUPABASE_URL`      | URL del proyecto Supabase                     |
| `SUPABASE_ANON_KEY` | Anon key pública                              |
| `API_BASE_URL`      | Base URL del API Node.js (Fase 2)             |
| `API_SECRET`        | Secret para autenticar el recolector (Fase 2) |

---

## Comandos frecuentes

```sh
# Instalar dependencias
flutter pub get

# Demo — data sembrada, streams periódicos, sin credenciales
flutter run
flutter run -d chrome

# Fase 1 — Supabase (requiere envs/sentinel.phase1.json)
flutter run --target lib/main_production.dart \
            --dart-define-from-file=envs/sentinel.phase1.json

# Fase 2 — Node.js API (requiere envs/sentinel.phase2.json)
flutter run --target lib/main_phase2.dart \
            --dart-define-from-file=envs/sentinel.phase2.json

# Análisis estático
flutter analyze
```

---

## Diseño — sistema de colores

No modificar los tokens de `AppColors`. El sistema de diseño usa:

- Fondo: `voidBlack` / `darkPanel`
- Acento primario: `primaryCyberTeal` (verde)
- Acento secundario: `neonShieldGreen` / `deepMonitoringCyan`
- Alertas: `warningAmber` → `criticalOrange` → `dangerRed`

---

## Convenciones

- Archivos: `snake_case.dart`
- Navegación: siempre `context.go()` — nunca `Navigator.push/pushNamed`
- Pantallas del shell: deben ser stateless cuando sea posible
- Fotos del equipo: colocar en `assets/team/` con nombre `team_<nombre>.png`

---

## Revisión de decisiones técnicas

Antes de implementar cualquier solución que Jair proponga, si existe un patrón
o herramienta de industria más estándar para ese problema, mencionarlo
brevemente con ventajas/desventajas antes de continuar. No bloquear la
implementación — solo informar para que él decida con criterio.

Contextos donde esto aplica con mayor frecuencia:

| Problema | Solución típica de principiante | Solución de industria |
|---|---|---|
| Usuario online/presencia | DB heartbeat + `expires_at` | WebSocket Presence (Supabase Presence, Socket.IO, Phoenix) |
| Caché de datos | Columna `expires_at` en DB | Redis con TTL nativo |
| Trabajo en background | `Timer.periodic` en cliente | Cola de trabajos (BullMQ, Sidekiq, pg_boss) |
| Notificaciones push | Polling periódico | FCM / APNs / WebPush |
| Rate limiting | Contador en DB | Redis sliding window |
| Búsqueda de texto | `LIKE '%query%'` en SQL | Full-text search (pg `tsvector`, Typesense, Meilisearch) |
| Auth tokens | Token custom en tabla DB | JWT estándar / OAuth 2.0 |
| Estado compartido entre tabs | `localStorage` polling | BroadcastChannel API / SharedWorker |

---

## Etapas del proyecto

| Etapa                            | Fecha        | Estado         |
| -------------------------------- | ------------ | -------------- |
| 1 — Infraestructura + SNMP       | 12 mayo 2025 | ✅ Completada  |
| 2 — Sistema web + almacenamiento | 19 mayo 2025 | 🔄 En progreso |
| 3 — Costeo y concurrencia        | 26 mayo 2025 | ⏳ Pendiente   |
