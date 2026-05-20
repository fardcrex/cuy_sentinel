# Supabase Setup — Cuy Sentinel (Fase 1)

Guía completa para configurar la base de datos Supabase que usa el panel en Fase 1.

---

## 1. Crear el proyecto en Supabase

1. Ir a <https://supabase.com> → **New project**
2. Anotar la **Project URL** y la **anon key** (Settings → API)
3. Copiarlas en `envs/sentinel.phase1.json`:

```json
{
  "SUPABASE_URL": "https://<tu-proyecto>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-key>",
  "API_BASE_URL": "",
  "API_SECRET": ""
}
```

---

## 2. Crear las tablas

Abrir **SQL Editor** en el dashboard de Supabase y ejecutar el archivo completo:

```
cuy_sentinel_go/database/schema.sql
```

Esto crea las siguientes tablas:

| Tabla | Descripción |
|---|---|
| `users` | Perfiles del panel (vinculados a Supabase Auth) |
| `user_access_logs` | Log de login/logout por usuario |
| `monitored_services` | Servicios SNMP registrados (Passbolt, ChkMonitor) |
| `metrics` | Métricas recolectadas cada 5 min por el agente Go |
| `service_events` | Caídas, recuperaciones y degradaciones |
| `alert_thresholds` | Umbrales que disparan alertas |
| `alert_events` | Alertas disparadas al superar un umbral |
| `collector_runs` | Automonitoreo del agente recolector |

También crea dos funciones RPC usadas por el panel:
- `get_database_health()` — snapshot de salud de la BD
- `get_table_stats()` — estadísticas por tabla

---

## 3. Registrar el usuario administrador

### 3.1 Crear cuenta en Supabase Auth

En el dashboard: **Authentication → Users → Invite user** (o usar el formulario de login del panel).

### 3.2 Vincular con la tabla `users`

Después de crear la cuenta, obtener el UUID del auth user:

```sql
SELECT id, email FROM auth.users WHERE email = 'admin@admin.com';
```

Insertar el perfil en la tabla `users` usando ese UUID:

```sql
INSERT INTO users (id, email, display_name, role, created_at)
VALUES (
  '<uuid-del-select-anterior>',
  'admin@admin.com',
  'Admin',
  'admin',
  now()
);
```

> Es importante que `users.id` coincida con `auth.users.id` para que la sesión enlace correctamente con el perfil del panel.

---

## 4. Habilitar Row Level Security (RLS)

Supabase activa RLS por defecto. Sin políticas, ninguna tabla devuelve datos al cliente.

### 4.1 Activar RLS en todas las tablas

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitored_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_thresholds ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE collector_runs ENABLE ROW LEVEL SECURITY;
```

### 4.2 Políticas de lectura (usuarios autenticados)

```sql
CREATE POLICY "auth read users" ON users FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read access_logs" ON user_access_logs FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read services" ON monitored_services FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read metrics" ON metrics FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read service_events" ON service_events FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read thresholds" ON alert_thresholds FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read alert_events" ON alert_events FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth read collector_runs" ON collector_runs FOR SELECT TO authenticated USING (true);
```

### 4.3 Política de escritura (resolver alertas)

```sql
CREATE POLICY "auth update alert_events" ON alert_events FOR UPDATE TO authenticated USING (true);
```

---

## 5. Datos de prueba para presentación

### Insertar alertas una por una (en orden de severidad)

Primero obtener los IDs de los servicios:

```sql
SELECT id, service_name FROM monitored_services;
```

Luego ejecutar cada INSERT por separado para demostrar el Realtime en vivo:

```sql
-- INFO
INSERT INTO alert_events
  (service_id, service_name, metric_name, current_value, threshold_value, severity, triggered_at, resolved)
VALUES (
  '<id-passbolt>', 'Passbolt', 'bandwidth_in_mb', 210.5, 200.0, 'info', now(), false
);
```

```sql
-- WARNING
INSERT INTO alert_events
  (service_id, service_name, metric_name, current_value, threshold_value, severity, triggered_at, resolved)
VALUES (
  '<id-chkmonitor>', 'ChkMonitor', 'disk_usage_percent', 78.4, 75.0, 'warning', now(), false
);
```

```sql
-- CRITICAL
INSERT INTO alert_events
  (service_id, service_name, metric_name, current_value, threshold_value, severity, triggered_at, resolved)
VALUES (
  '<id-passbolt>', 'Passbolt', 'cpu_usage_percent', 93.7, 90.0, 'critical', now(), false
);
```

```sql
-- NUCLEAR
INSERT INTO alert_events
  (service_id, service_name, metric_name, current_value, threshold_value, severity, triggered_at, resolved)
VALUES (
  '<id-chkmonitor>', 'ChkMonitor', 'snmp_latency_ms', 850.0, 500.0, 'nuclear', now(), false
);
```

---

## 6. Migración incremental (si las tablas ya existen)

Si el schema ya fue ejecutado y solo se necesita aplicar cambios posteriores, usar:

```sql
-- Añadir severidad 'nuclear' al CHECK (si no estaba)
ALTER TABLE alert_thresholds DROP CONSTRAINT IF EXISTS alert_thresholds_severity_check;
ALTER TABLE alert_thresholds ADD CONSTRAINT alert_thresholds_severity_check
  CHECK (severity IN ('critical', 'nuclear', 'warning', 'info'));

ALTER TABLE alert_events DROP CONSTRAINT IF EXISTS alert_events_severity_check;
ALTER TABLE alert_events ADD CONSTRAINT alert_events_severity_check
  CHECK (severity IN ('critical', 'nuclear', 'warning', 'info'));
```

```sql
-- Cambiar service_id a TEXT si los IDs no son UUID válidos
ALTER TABLE alert_events ALTER COLUMN service_id TYPE TEXT;
ALTER TABLE service_events ALTER COLUMN service_id TYPE TEXT;
ALTER TABLE metrics ALTER COLUMN service_id TYPE TEXT;
ALTER TABLE alert_thresholds ALTER COLUMN service_id TYPE TEXT;
```

---

## 7. Verificar que todo funciona

```sql
-- Servicios registrados
SELECT service_name, host_ip, snmp_port, enabled FROM monitored_services;

-- Usuario vinculado correctamente
SELECT u.id, u.email, u.role FROM users u
JOIN auth.users a ON a.id = u.id;

-- Alertas activas
SELECT service_name, metric_name, severity, triggered_at
FROM alert_events WHERE resolved = false
ORDER BY triggered_at DESC;
```
