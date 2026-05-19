# CLAUDE.md — Cuy Sentinel

Panel de monitoreo externo para infraestructura dockerizada (Passbolt + ChkMonitor) vía SNMP.
Proyecto universitario — Programación de Interfaces y Dispositivos Periféricos.
Prof. Rene Alejandro Zamudio Ariza.

Equipo: Jair Conislla Bocangel · Daniel Rojas Sanchez · Jheampierre Ralli Peralta.

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
monitored_services -- Passbolt y ChkMonitor registrados
metrics            -- CPU%, RAM, disco%, BW, uptime, status, latencia SNMP · cada 5 min
service_events     -- historial de caídas, recuperaciones y degradaciones
collector_runs     -- automonitoreo del agente Go (éxito/fallo, duración, versión)
```

Ver `cuy_sentinel_go/database/schema.sql` para DDL completo con índices.

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

## Etapas del proyecto

| Etapa                            | Fecha        | Estado         |
| -------------------------------- | ------------ | -------------- |
| 1 — Infraestructura + SNMP       | 12 mayo 2025 | ✅ Completada  |
| 2 — Sistema web + almacenamiento | 19 mayo 2025 | 🔄 En progreso |
| 3 — Costeo y concurrencia        | 26 mayo 2025 | ⏳ Pendiente   |
