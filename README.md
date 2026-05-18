# Cuy Sentinel

Panel de monitoreo externo multiplataforma para infraestructura dockerizada (Passbolt + ChkMonitor) vía SNMP.

**Proyecto universitario** — Programación de Interfaces y Dispositivos Periféricos  
Prof. Rene Alejandro Zamudio Ariza  
Equipo: Jair Conislla Bocangel · Daniel Rojas Sanchez · Jheampierre Ralli Peralta

---

## Stack

| Área | Tecnología |
|---|---|
| Panel | Flutter multiplataforma (web, mobile, desktop) |
| Routing | go_router con ShellRoute |
| Recolector | Go (`cuy_sentinel_go/`) |
| BD Fase 1 | Supabase (PostgreSQL cloud) |
| BD Fase 2 | PostgreSQL propio + réplica streaming WAL |
| API Fase 2 | Node.js + Socket.IO |
| SNMP | Passbolt :1161 · ChkMonitor :2161 |
| SO despliegue | Ubuntu 24.04 LTS |

---

## Pantallas del panel

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/dashboard` | Dashboard | Resumen general: 4 stat cards, gráficas CPU/RAM/Disco/BW, estado de servicios, salud del recolector, eventos recientes |
| `/services` | Servicios | Detalle de cada servicio: métricas actuales, barras de progreso, info SNMP |
| `/metrics` | Métricas | Gráficas históricas con selector de servicio y métrica, latencia SNMP, disponibilidad |
| `/alerts` | Alertas | Umbrales superados derivados de métricas + historial de incidentes (service_events) |
| `/users` | Usuarios | Lista de usuarios del panel, estado online/offline, log de accesos recientes |

---

## Correr el proyecto

```sh
cd cuy_sentinel

# Sin credenciales — modo demo/visual
flutter run

# Fase 1 con Supabase (requiere envs/sentinel.phase1.json)
flutter run --dart-define-from-file=envs/sentinel.phase1.json

# Web
flutter run -d chrome --dart-define-from-file=envs/sentinel.phase1.json
```

---

## Base de datos (cuy_sentinel_go)

```
users              — usuarios del panel (auth Fase 1 via Supabase / Fase 2 propia)
monitored_services — Passbolt y ChkMonitor registrados
metrics            — CPU, RAM, disco, BW, uptime, status, latencia SNMP · cada 5 min
service_events     — historial de caídas, recuperaciones y degradaciones
collector_runs     — automonitoreo del agente Go (éxito/fallo, duración, versión)
```

Ver `cuy_sentinel_go/database/schema.sql` para DDL completo.
