# Backend Monorepo (cuy_sentinel_backend/) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Crear `cuy_sentinel_backend/` — monorepo con Node.js API, Go collector SNMP, Patroni (HA PostgreSQL), etcd y HAProxy, todo orquestado con un único `docker-compose.yml`, listo para la presentación del 26 mayo.

**Architecture:** Flutter → Node.js API (Express + Socket.IO, :3000) → HAProxy (:5432 writes / :5433 reads) → Patroni cluster (2 nodos PostgreSQL 15). Go collector → SNMP → PostgreSQL via HAProxy. Si cae un nodo Patroni, HAProxy reroutes automáticamente — cero cambios en Node.js ni Flutter.

**Tech Stack:** Node.js 20, Express, Socket.IO, jsonwebtoken, pg (node-postgres), Go 1.22, gosnmp, Patroni 3.3, etcd 3.5, HAProxy 2.8, PostgreSQL 15, Docker Compose v2.

---

## File Map

| Ruta | Acción | Propósito |
|------|--------|-----------|
| `cuy_sentinel_backend/docker-compose.yml` | Crear | Orquesta todos los servicios |
| `cuy_sentinel_backend/init/01_schema.sql` | Crear | Schema sin RLS de Supabase, con usuario `app` |
| `cuy_sentinel_backend/patroni/patroni1.yml` | Crear | Config Patroni nodo 1 |
| `cuy_sentinel_backend/patroni/patroni2.yml` | Crear | Config Patroni nodo 2 |
| `cuy_sentinel_backend/patroni/Dockerfile` | Crear | Imagen Patroni + PostgreSQL |
| `cuy_sentinel_backend/haproxy/haproxy.cfg` | Crear | Proxy con health-check de Patroni |
| `cuy_sentinel_backend/go_collector/main.go` | Crear | Entry-point del collector |
| `cuy_sentinel_backend/go_collector/go.mod` | Crear | Módulo Go + gosnmp |
| `cuy_sentinel_backend/go_collector/internal/collector/snmp_collector.go` | Crear | Implementación SNMP real |
| `cuy_sentinel_backend/go_collector/internal/collector/collector.go` | Crear | Interfaces (migrado) |
| `cuy_sentinel_backend/go_collector/internal/storage/postgres_storage.go` | Crear | Implementación PostgreSQL + service_events |
| `cuy_sentinel_backend/go_collector/internal/storage/storage.go` | Crear | Interfaz con SaveMetric + RecordDown + RecordRecovered |
| `cuy_sentinel_backend/go_collector/Dockerfile` | Crear | Multi-stage Go build |
| `cuy_sentinel_backend/node_api/package.json` | Crear | Dependencias Node.js |
| `cuy_sentinel_backend/node_api/src/db.js` | Crear | Pool pg → HAProxy |
| `cuy_sentinel_backend/node_api/src/auth.js` | Crear | Middleware JWT |
| `cuy_sentinel_backend/node_api/src/routes/auth.js` | Crear | POST /api/auth/login, logout |
| `cuy_sentinel_backend/node_api/src/routes/users.js` | Crear | GET/PATCH /api/users |
| `cuy_sentinel_backend/node_api/src/routes/services.js` | Crear | GET /api/services |
| `cuy_sentinel_backend/node_api/src/routes/metrics.js` | Crear | GET /api/metrics |
| `cuy_sentinel_backend/node_api/src/routes/alerts.js` | Crear | GET/PATCH /api/alerts, GET /api/thresholds |
| `cuy_sentinel_backend/node_api/src/index.js` | Crear | Express + Socket.IO server |
| `cuy_sentinel_backend/node_api/Dockerfile` | Crear | Imagen Node.js producción |

---

## Task 1: Monorepo scaffold + migración Go collector

**Files:**
- Create: `cuy_sentinel_backend/` (directorio raíz)
- Create: `cuy_sentinel_backend/go_collector/` (todo el contenido de `cuy_sentinel_go/`)

- [ ] **Step 1: Crear estructura de carpetas**

```bash
mkdir -p /Users/jairconislla/Projects/cuy_sentinel_backend
cd /Users/jairconislla/Projects/cuy_sentinel_backend
mkdir -p go_collector/internal/collector
mkdir -p go_collector/internal/storage
mkdir -p node_api/src/routes
mkdir -p patroni
mkdir -p haproxy
mkdir -p init
```

- [ ] **Step 2: Migrar interfaces del collector Go**

Crear `go_collector/internal/collector/collector.go`:

```go
package collector

type SNMPTarget struct {
	ServiceID string
	Host      string
	Port      int
	Community string
}

type Collector interface {
	Collect(target SNMPTarget) (Metrics, error)
}

type Metrics struct {
	CPUUsagePercent  float64
	RAMUsageMB       int
	RAMTotalMB       int
	DiskUsagePercent float64
	BandwidthInMB    float64
	BandwidthOutMB   float64
	UptimeSeconds    int64
	ServiceUp        bool
	SNMPLatencyMs    int
}
```

Crear `go_collector/internal/storage/storage.go`:

```go
package storage

import "time"

type MetricRecord struct {
	ServiceID        string
	CPUUsagePercent  float64
	RAMUsageMB       int
	RAMTotalMB       int
	DiskUsagePercent float64
	BandwidthInMB    float64
	BandwidthOutMB   float64
	UptimeSeconds    int64
	ServiceStatus    string // 'online' | 'offline' | 'degraded'
	SNMPLatencyMs    int
	CollectedAt      time.Time
}

type Storage interface {
	SaveMetric(record MetricRecord) error
	GetServices() ([]MonitoredService, error)
	// RecordDown abre un evento service_events (event_type='down') si no hay uno abierto ya.
	// Retorna el ID del evento abierto (nuevo o existente).
	RecordDown(serviceID string, cause string) (string, error)
	// RecordRecovered cierra el evento abierto y crea uno de tipo 'recovered'.
	RecordRecovered(serviceID string, openEventID string) error
	// ActiveEvent retorna el ID del evento 'down' aún abierto (ended_at IS NULL) para ese servicio,
	// o "" si no hay ninguno.
	ActiveEvent(serviceID string) (string, error)
	Close() error
}

type MonitoredService struct {
	ID        string
	Name      string
	Host      string
	SNMPPort  int
	Community string
	Enabled   bool
}
```

- [ ] **Step 3: Crear go.mod con dependencia gosnmp**

Crear `go_collector/go.mod`:

```go
module github.com/cuy-sentinel/collector

go 1.22

require (
	github.com/gosnmp/gosnmp v1.37.0
	github.com/lib/pq v1.10.9
)
```

- [ ] **Step 4: Ejecutar go mod tidy para resolver dependencias**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend/go_collector
go mod tidy
```

Expected: descarga gosnmp y lib/pq, genera go.sum.

- [ ] **Step 5: Commit**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
git init
git add .
git commit -m "chore: scaffold cuy_sentinel_backend monorepo + migrate Go interfaces"
```

---

## Task 2: Schema SQL adaptado (sin Supabase)

**Files:**
- Create: `cuy_sentinel_backend/init/01_schema.sql`

- [ ] **Step 1: Crear script de inicialización**

Crear `init/01_schema.sql`:

```sql
-- ============================================================
-- Cuy Sentinel — Fase 2 schema (PostgreSQL 15 standalone)
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Usuario de aplicación (Node.js API + Go collector)
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app') THEN
    CREATE ROLE app LOGIN PASSWORD 'app_secret_2025';
  END IF;
END $$;

-- =============================================================
-- TABLAS
-- =============================================================
CREATE TABLE IF NOT EXISTS users (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email             TEXT NOT NULL UNIQUE,
    password_hash     TEXT NOT NULL,
    display_name      TEXT NOT NULL,
    role              TEXT NOT NULL DEFAULT 'viewer'
                      CHECK (role IN ('master', 'admin', 'viewer')),
    last_login        TIMESTAMPTZ,
    session_expires_at TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_access_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name    TEXT NOT NULL,
    action          TEXT NOT NULL CHECK (action IN ('login', 'logout')),
    timestamp       TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip_address      TEXT,
    device_name     TEXT,
    device_platform TEXT
);

CREATE TABLE IF NOT EXISTS monitored_services (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name    TEXT NOT NULL UNIQUE,
    container_name  TEXT NOT NULL,
    host_ip         TEXT NOT NULL,
    snmp_port       INTEGER NOT NULL,
    description     TEXT,
    enabled         BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS metrics (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id          UUID NOT NULL REFERENCES monitored_services(id) ON DELETE CASCADE,
    cpu_usage_percent   NUMERIC(5,2),
    ram_usage_mb        INTEGER,
    ram_total_mb        INTEGER,
    disk_usage_percent  NUMERIC(5,2),
    bandwidth_in_mb     NUMERIC(10,3),
    bandwidth_out_mb    NUMERIC(10,3),
    uptime_seconds      BIGINT,
    service_status      TEXT NOT NULL DEFAULT 'online'
                        CHECK (service_status IN ('online','offline','degraded','warning')),
    snmp_latency_ms     INTEGER,
    snmp_loss_percent   NUMERIC(5,2),
    collected_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS service_events (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id  UUID NOT NULL REFERENCES monitored_services(id) ON DELETE CASCADE,
    event_type  TEXT NOT NULL CHECK (event_type IN ('down','recovered','degraded','warning')),
    started_at  TIMESTAMPTZ NOT NULL,
    ended_at    TIMESTAMPTZ,
    cause       TEXT,
    resolved    BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alert_thresholds (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id      UUID REFERENCES monitored_services(id) ON DELETE CASCADE,
    metric_name     TEXT NOT NULL CHECK (metric_name IN (
                        'cpu_usage_percent','ram_usage_mb','disk_usage_percent',
                        'bandwidth_in_mb','bandwidth_out_mb','snmp_latency_ms')),
    threshold_value NUMERIC(12,3) NOT NULL,
    severity        TEXT NOT NULL CHECK (severity IN ('critical','nuclear','warning','info')),
    enabled         BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS alert_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id      UUID NOT NULL REFERENCES monitored_services(id) ON DELETE CASCADE,
    service_name    TEXT NOT NULL,
    metric_name     TEXT NOT NULL,
    current_value   NUMERIC(12,3) NOT NULL,
    threshold_value NUMERIC(12,3) NOT NULL,
    severity        TEXT NOT NULL CHECK (severity IN ('critical','nuclear','warning','info')),
    triggered_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved        BOOLEAN NOT NULL DEFAULT false,
    resolved_at     TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS collector_runs (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    started_at        TIMESTAMPTZ NOT NULL,
    finished_at       TIMESTAMPTZ,
    services_polled   INTEGER NOT NULL DEFAULT 0,
    success           BOOLEAN NOT NULL DEFAULT false,
    error_message     TEXT,
    collector_version TEXT
);

-- =============================================================
-- ÍNDICES
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_metrics_service_collected
    ON metrics (service_id, collected_at DESC);
CREATE INDEX IF NOT EXISTS idx_metrics_collected_desc
    ON metrics (collected_at DESC);
CREATE INDEX IF NOT EXISTS idx_alert_events_active
    ON alert_events (resolved, triggered_at DESC) WHERE resolved = false;
CREATE INDEX IF NOT EXISTS idx_access_logs_user
    ON user_access_logs (user_id, timestamp DESC);

-- =============================================================
-- PERMISOS para rol 'app'
-- =============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app;

-- =============================================================
-- DATOS SEMILLA
-- =============================================================
INSERT INTO monitored_services (service_name, container_name, host_ip, snmp_port, description)
VALUES
    ('Passbolt',   'passbolt',   'passbolt',   1161, 'Gestor de contraseñas corporativo'),
    ('ChkMonitor', 'chkmonitor', 'chkmonitor', 2161, 'Monitor de disponibilidad web')
ON CONFLICT (service_name) DO NOTHING;

INSERT INTO alert_thresholds (metric_name, threshold_value, severity) VALUES
    ('cpu_usage_percent',  90.0,  'critical'),
    ('cpu_usage_percent',  75.0,  'warning'),
    ('disk_usage_percent', 90.0,  'critical'),
    ('snmp_latency_ms',    500.0, 'critical')
ON CONFLICT DO NOTHING;

-- Usuario master por defecto (password: sentinel2025)
-- Hash generado con bcrypt cost=10: $2b$10$...
-- Ejecutar en Node: require('bcrypt').hashSync('sentinel2025', 10)
-- Reemplazar el hash de abajo después de generarlo:
INSERT INTO users (email, password_hash, display_name, role)
VALUES ('master@cuy.local', '$2b$10$REEMPLAZAR_CON_HASH_REAL', 'Master Admin', 'master')
ON CONFLICT (email) DO NOTHING;

-- =============================================================
-- NOTIFY para Socket.IO (Go collector → Node.js push)
-- =============================================================
CREATE OR REPLACE FUNCTION notify_new_metric()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  PERFORM pg_notify('new_metric', row_to_json(NEW)::text);
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_metrics_notify
AFTER INSERT ON metrics
FOR EACH ROW EXECUTE FUNCTION notify_new_metric();
```

- [ ] **Step 2: Commit**

```bash
git add init/
git commit -m "feat: add Phase 2 schema with pg_notify trigger and app role"
```

---

## Task 3: Patroni + etcd config

**Files:**
- Create: `cuy_sentinel_backend/patroni/Dockerfile`
- Create: `cuy_sentinel_backend/patroni/patroni1.yml`
- Create: `cuy_sentinel_backend/patroni/patroni2.yml`

- [ ] **Step 1: Crear Dockerfile de Patroni**

Crear `patroni/Dockerfile`:

```dockerfile
FROM postgres:15

RUN apt-get update && apt-get install -y \
    python3 python3-pip curl \
    && pip3 install patroni[etcd3] psycopg2-binary \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["patroni"]
CMD ["/etc/patroni/patroni.yml"]
```

- [ ] **Step 2: Crear patroni1.yml**

Crear `patroni/patroni1.yml`:

```yaml
scope: cuy-sentinel-cluster
namespace: /db/
name: pg1

restapi:
  listen: 0.0.0.0:8008
  connect_address: patroni1:8008

etcd3:
  hosts: etcd:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:
        max_connections: 100
        wal_level: replica
        max_wal_senders: 5
        max_replication_slots: 5
        hot_standby: "on"
  initdb:
    - encoding: UTF8
    - data-checksums
  pg_hba:
    - host replication replicator 0.0.0.0/0 md5
    - host all all 0.0.0.0/0 md5
  users:
    admin:
      password: admin_pass_2025
      options:
        - createrole
        - createdb
    app:
      password: app_secret_2025
      options:
        - login

postgresql:
  listen: 0.0.0.0:5432
  connect_address: patroni1:5432
  data_dir: /data/patroni
  pgpass: /tmp/pgpass
  authentication:
    replication:
      username: replicator
      password: replicator_pass_2025
    superuser:
      username: postgres
      password: postgres_pass_2025
    rewind:
      username: rewind_user
      password: rewind_pass_2025
  parameters:
    unix_socket_directories: '.'

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
  nosync: false
```

- [ ] **Step 3: Crear patroni2.yml**

Crear `patroni/patroni2.yml`:

```yaml
scope: cuy-sentinel-cluster
namespace: /db/
name: pg2

restapi:
  listen: 0.0.0.0:8008
  connect_address: patroni2:8008

etcd3:
  hosts: etcd:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
  initdb:
    - encoding: UTF8
    - data-checksums
  pg_hba:
    - host replication replicator 0.0.0.0/0 md5
    - host all all 0.0.0.0/0 md5

postgresql:
  listen: 0.0.0.0:5432
  connect_address: patroni2:5432
  data_dir: /data/patroni
  pgpass: /tmp/pgpass
  authentication:
    replication:
      username: replicator
      password: replicator_pass_2025
    superuser:
      username: postgres
      password: postgres_pass_2025
    rewind:
      username: rewind_user
      password: rewind_pass_2025
  parameters:
    unix_socket_directories: '.'

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
  nosync: false
```

- [ ] **Step 4: Commit**

```bash
git add patroni/
git commit -m "feat: add Patroni HA config for 2-node PostgreSQL cluster"
```

---

## Task 4: HAProxy config

**Files:**
- Create: `cuy_sentinel_backend/haproxy/haproxy.cfg`

- [ ] **Step 1: Crear haproxy.cfg**

HAProxy usa el REST API de Patroni (`:8008/primary` devuelve 200 si el nodo es primary, `/replica` devuelve 200 si es réplica) como health check. Así redirige escrituras siempre al primary y lecturas a cualquier réplica disponible.

Crear `haproxy/haproxy.cfg`:

```
global
    maxconn 100
    log stdout format raw local0

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen stats
    mode http
    bind *:7000
    stats enable
    stats uri /

# Escrituras → solo el nodo PRIMARY (Patroni devuelve 200 en /primary)
frontend pg_write
    bind *:5432
    default_backend pg_primary

backend pg_primary
    option httpchk GET /primary
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server patroni1 patroni1:5432 check port 8008
    server patroni2 patroni2:5432 check port 8008

# Lecturas → cualquier nodo REPLICA (Patroni devuelve 200 en /replica)
frontend pg_read
    bind *:5433
    default_backend pg_replicas

backend pg_replicas
    balance roundrobin
    option httpchk GET /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server patroni1 patroni1:5432 check port 8008
    server patroni2 patroni2:5432 check port 8008
```

- [ ] **Step 2: Commit**

```bash
git add haproxy/
git commit -m "feat: add HAProxy config — writes :5432→primary, reads :5433→replicas"
```

---

## Task 5: docker-compose.yml unificado

**Files:**
- Create: `cuy_sentinel_backend/docker-compose.yml`

- [ ] **Step 1: Crear docker-compose.yml**

Este compose integra los servicios del docker-compose existente (passbolt, chkmonitor) con los nuevos (etcd, patroni, haproxy, node_api, go_collector).

Crear `docker-compose.yml`:

```yaml
version: "3.8"

networks:
  sentinel:
    driver: bridge

volumes:
  patroni1_data:
  patroni2_data:
  etcd_data:

services:
  # ─── Servicios SNMP existentes ─────────────────────────────
  passbolt:
    build:
      context: .
      dockerfile: Dockerfile.snmp
    container_name: passbolt
    networks: [sentinel]
    ports:
      - "8080:80"
      - "1161:161/udp"

  chkmonitor:
    build:
      context: .
      dockerfile: Dockerfile.snmp
    container_name: chkmonitor
    networks: [sentinel]
    ports:
      - "8081:80"
      - "2161:161/udp"

  # ─── etcd (consenso Patroni) ────────────────────────────────
  etcd:
    image: quay.io/coreos/etcd:v3.5.9
    container_name: etcd
    networks: [sentinel]
    environment:
      ETCD_NAME: etcd0
      ETCD_DATA_DIR: /etcd-data
      ETCD_LISTEN_CLIENT_URLS: http://0.0.0.0:2379
      ETCD_ADVERTISE_CLIENT_URLS: http://etcd:2379
      ETCD_LISTEN_PEER_URLS: http://0.0.0.0:2380
      ETCD_INITIAL_ADVERTISE_PEER_URLS: http://etcd:2380
      ETCD_INITIAL_CLUSTER: etcd0=http://etcd:2380
      ETCD_INITIAL_CLUSTER_STATE: new
      ETCD_INITIAL_CLUSTER_TOKEN: sentinel-etcd-token
      ALLOW_NONE_AUTHENTICATION: "yes"
    volumes:
      - etcd_data:/etcd-data
    ports:
      - "2379:2379"

  # ─── Patroni nodo 1 (primary inicial) ──────────────────────
  patroni1:
    build:
      context: ./patroni
      dockerfile: Dockerfile
    container_name: patroni1
    networks: [sentinel]
    environment:
      PATRONI_CONFIGURATION: /etc/patroni/patroni.yml
    volumes:
      - ./patroni/patroni1.yml:/etc/patroni/patroni.yml:ro
      - patroni1_data:/data/patroni
    ports:
      - "5434:5432"   # debug directo al nodo 1
      - "8008:8008"   # Patroni REST API nodo 1
    depends_on:
      - etcd

  # ─── Patroni nodo 2 (replica inicial) ──────────────────────
  patroni2:
    build:
      context: ./patroni
      dockerfile: Dockerfile
    container_name: patroni2
    networks: [sentinel]
    environment:
      PATRONI_CONFIGURATION: /etc/patroni/patroni.yml
    volumes:
      - ./patroni/patroni2.yml:/etc/patroni/patroni.yml:ro
      - patroni2_data:/data/patroni
    ports:
      - "5435:5432"   # debug directo al nodo 2
      - "8009:8008"   # Patroni REST API nodo 2
    depends_on:
      - etcd

  # ─── HAProxy (single-endpoint) ─────────────────────────────
  haproxy:
    image: haproxy:2.8
    container_name: haproxy
    networks: [sentinel]
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
    ports:
      - "5432:5432"   # escrituras → primary
      - "5433:5433"   # lecturas → replicas
      - "7000:7000"   # stats dashboard
    depends_on:
      - patroni1
      - patroni2

  # ─── Node.js API ───────────────────────────────────────────
  node_api:
    build:
      context: ./node_api
    container_name: node_api
    networks: [sentinel]
    environment:
      PG_HOST: haproxy
      PG_PORT: 5432
      PG_DATABASE: postgres
      PG_USER: app
      PG_PASSWORD: app_secret_2025
      JWT_SECRET: cuy_sentinel_jwt_secret_2025
      PORT: 3000
    ports:
      - "3000:3000"
    depends_on:
      - haproxy

  # ─── Go collector ──────────────────────────────────────────
  go_collector:
    build:
      context: ./go_collector
    container_name: go_collector
    networks: [sentinel]
    environment:
      PG_DSN: "postgres://app:app_secret_2025@haproxy:5432/postgres?sslmode=disable"
      SNMP_INTERVAL: "300"   # 5 minutos
    depends_on:
      - haproxy
      - passbolt
      - chkmonitor
```

> **Nota:** el `init/01_schema.sql` se aplica manualmente la primera vez (ver Task 2 step 3 más abajo) o montando el volumen en patroni1. La forma más simple para la demo: correr `psql -h localhost -p 5432 -U app -d postgres -f init/01_schema.sql` después de que Patroni esté healthy.

- [ ] **Step 2: Instrucción de arranque inicial**

Después de `docker compose up -d`, esperar que Patroni elija un primary (~30s) y aplicar el schema:

```bash
# Verificar que Patroni eligió primary
curl http://localhost:8008/primary   # debe devolver 200 desde el nodo 1
curl http://localhost:8009/primary   # debe devolver 503 (es réplica)

# Aplicar schema
PGPASSWORD=app_secret_2025 psql \
  -h localhost -p 5432 \
  -U app -d postgres \
  -f init/01_schema.sql
```

- [ ] **Step 3: Commit**

```bash
git add docker-compose.yml
git commit -m "feat: unified docker-compose — etcd + patroni + haproxy + node_api + go_collector"
```

---

## Task 6: Node.js API — scaffold + pool PostgreSQL

**Files:**
- Create: `node_api/package.json`
- Create: `node_api/Dockerfile`
- Create: `node_api/src/db.js`
- Create: `node_api/src/index.js`

- [ ] **Step 1: Crear package.json**

Crear `node_api/package.json`:

```json
{
  "name": "cuy-sentinel-api",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js"
  },
  "dependencies": {
    "bcrypt": "^5.1.1",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.2",
    "pg": "^8.11.3",
    "socket.io": "^4.7.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
```

- [ ] **Step 2: Crear Dockerfile del API**

Crear `node_api/Dockerfile`:

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm install --omit=dev
COPY src/ ./src/
EXPOSE 3000
CMD ["node", "src/index.js"]
```

- [ ] **Step 3: Crear db.js — pool pg**

Crear `node_api/src/db.js`:

```js
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.PG_HOST || 'localhost',
  port: parseInt(process.env.PG_PORT || '5432'),
  database: process.env.PG_DATABASE || 'postgres',
  user: process.env.PG_USER || 'app',
  password: process.env.PG_PASSWORD || 'app_secret_2025',
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

module.exports = pool;
```

- [ ] **Step 4: Crear index.js — Express + Socket.IO + pg LISTEN**

Crear `node_api/src/index.js`:

```js
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth',       require('./routes/auth'));
app.use('/api/users',      require('./routes/users'));
app.use('/api/services',   require('./routes/services'));
app.use('/api/metrics',    require('./routes/metrics'));
app.use('/api/alerts',     require('./routes/alerts'));

app.get('/health', (_, res) => res.json({ status: 'ok' }));

// pg LISTEN/NOTIFY → Socket.IO broadcast
const listenerPool = new Pool({
  host: process.env.PG_HOST || 'localhost',
  port: parseInt(process.env.PG_PORT || '5432'),
  database: process.env.PG_DATABASE || 'postgres',
  user: process.env.PG_USER || 'app',
  password: process.env.PG_PASSWORD || 'app_secret_2025',
});

listenerPool.connect().then(client => {
  client.query('LISTEN new_metric');
  client.on('notification', msg => {
    io.emit('metric', JSON.parse(msg.payload));
  });
}).catch(err => console.error('LISTEN error:', err.message));

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`API listening on :${PORT}`));
```

- [ ] **Step 5: Instalar dependencias localmente para verificar**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend/node_api
npm install
```

Expected: node_modules/ creado, 0 vulnerabilities.

- [ ] **Step 6: Commit**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
git add node_api/
git commit -m "feat: add Node.js API scaffold with Express, Socket.IO, pg pool"
```

---

## Task 7: Middleware JWT + ruta de auth

**Files:**
- Create: `node_api/src/auth.js`
- Create: `node_api/src/routes/auth.js`

- [ ] **Step 1: Crear middleware JWT**

Crear `node_api/src/auth.js`:

```js
const jwt = require('jsonwebtoken');

const SECRET = process.env.JWT_SECRET || 'cuy_sentinel_jwt_secret_2025';

function signToken(payload) {
  return jwt.sign(payload, SECRET, { expiresIn: '8h' });
}

function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token requerido' });
  }
  try {
    req.user = jwt.verify(header.slice(7), SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Token inválido o expirado' });
  }
}

module.exports = { signToken, requireAuth };
```

- [ ] **Step 2: Crear ruta de auth**

Crear `node_api/src/routes/auth.js`:

```js
const router = require('express').Router();
const bcrypt = require('bcrypt');
const pool = require('../db');
const { signToken, requireAuth } = require('../auth');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'email y password requeridos' });
  }
  try {
    const { rows } = await pool.query(
      'SELECT id, email, password_hash, display_name, role FROM users WHERE email = $1',
      [email]
    );
    const user = rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: 'Credenciales incorrectas' });
    }
    const token = signToken({ id: user.id, email: user.email, role: user.role });
    await pool.query(
      `INSERT INTO user_access_logs (user_id, display_name, action, ip_address)
       VALUES ($1, $2, 'login', $3)`,
      [user.id, user.display_name, req.ip]
    );
    await pool.query(
      'UPDATE users SET last_login = now() WHERE id = $1',
      [user.id]
    );
    res.json({
      token,
      user: { id: user.id, email: user.email, displayName: user.display_name, role: user.role },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/auth/logout
router.post('/logout', requireAuth, async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT display_name FROM users WHERE id = $1',
      [req.user.id]
    );
    await pool.query(
      `INSERT INTO user_access_logs (user_id, display_name, action, ip_address)
       VALUES ($1, $2, 'logout', $3)`,
      [req.user.id, rows[0]?.display_name ?? '', req.ip]
    );
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

- [ ] **Step 3: Generar hash del password master para el seed**

Ejecutar localmente para obtener el hash real:

```bash
node -e "const bcrypt=require('bcrypt'); bcrypt.hash('sentinel2025',10).then(h=>console.log(h))"
```

Copiar el hash resultante y reemplazar `$2b$10$REEMPLAZAR_CON_HASH_REAL` en `init/01_schema.sql`.

- [ ] **Step 4: Commit**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
git add node_api/src/auth.js node_api/src/routes/auth.js init/01_schema.sql
git commit -m "feat: add JWT auth middleware + login/logout routes"
```

---

## Task 8: Rutas de usuarios, servicios, métricas y alertas

**Files:**
- Create: `node_api/src/routes/users.js`
- Create: `node_api/src/routes/services.js`
- Create: `node_api/src/routes/metrics.js`
- Create: `node_api/src/routes/alerts.js`

- [ ] **Step 1: Crear routes/users.js**

```js
const router = require('express').Router();
const pool = require('../db');
const { requireAuth } = require('../auth');

// GET /api/users — lista de usuarios (sin password_hash)
router.get('/', requireAuth, async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT id, email, display_name, role, last_login, created_at
       FROM users ORDER BY created_at ASC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/users/:id/role — cambiar rol (solo admin/master)
router.patch('/:id/role', requireAuth, async (req, res) => {
  if (!['admin', 'master'].includes(req.user.role)) {
    return res.status(403).json({ error: 'Sin permisos' });
  }
  const { role } = req.body;
  if (!['viewer', 'admin', 'master'].includes(role)) {
    return res.status(400).json({ error: 'Rol inválido' });
  }
  try {
    const { rowCount } = await pool.query(
      'UPDATE users SET role = $1 WHERE id = $2',
      [role, req.params.id]
    );
    if (rowCount === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

- [ ] **Step 2: Crear routes/services.js**

```js
const router = require('express').Router();
const pool = require('../db');
const { requireAuth } = require('../auth');

// GET /api/services
router.get('/', requireAuth, async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM monitored_services WHERE enabled = true ORDER BY service_name'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

- [ ] **Step 3: Crear routes/metrics.js**

```js
const router = require('express').Router();
const pool = require('../db');
const { requireAuth } = require('../auth');

// GET /api/metrics/latest — última métrica por servicio
router.get('/latest', requireAuth, async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT DISTINCT ON (service_id) *
      FROM metrics
      ORDER BY service_id, collected_at DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/metrics/:serviceId?limit=50 — historial de un servicio
router.get('/:serviceId', requireAuth, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit || '50'), 500);
  try {
    const { rows } = await pool.query(
      `SELECT * FROM metrics WHERE service_id = $1
       ORDER BY collected_at DESC LIMIT $2`,
      [req.params.serviceId, limit]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

- [ ] **Step 4: Crear routes/alerts.js**

```js
const router = require('express').Router();
const pool = require('../db');
const { requireAuth } = require('../auth');

// GET /api/alerts — alertas activas
router.get('/', requireAuth, async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT * FROM alert_events
       WHERE resolved = false
       ORDER BY triggered_at DESC LIMIT 100`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/alerts/:id/resolve — resolver alerta
router.patch('/:id/resolve', requireAuth, async (req, res) => {
  if (!['admin', 'master'].includes(req.user.role)) {
    return res.status(403).json({ error: 'Sin permisos' });
  }
  try {
    const { rowCount } = await pool.query(
      `UPDATE alert_events SET resolved = true, resolved_at = now()
       WHERE id = $1 AND resolved = false`,
      [req.params.id]
    );
    if (rowCount === 0) return res.status(404).json({ error: 'Alerta no encontrada o ya resuelta' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/thresholds — umbrales configurados
router.get('/thresholds', requireAuth, async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM alert_thresholds WHERE enabled = true ORDER BY metric_name'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

- [ ] **Step 5: Commit**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
git add node_api/src/routes/
git commit -m "feat: add REST routes — users, services, metrics, alerts"
```

---

## Task 9: Go collector — implementación SNMP + PostgreSQL

**Files:**
- Create: `go_collector/internal/collector/snmp_collector.go`
- Create: `go_collector/internal/storage/postgres_storage.go`
- Modify: `go_collector/main.go`
- Create: `go_collector/Dockerfile`

- [ ] **Step 1: Implementar SNMPCollector**

Crear `go_collector/internal/collector/snmp_collector.go`:

```go
package collector

import (
	"fmt"
	"time"

	"github.com/gosnmp/gosnmp"
)

// OIDs estándar (MIB-II + HOST-RESOURCES)
const (
	oidSysUptime       = "1.3.6.1.2.1.1.3.0"
	oidIfInOctets      = "1.3.6.1.2.1.2.2.1.10.1"
	oidIfOutOctets     = "1.3.6.1.2.1.2.2.1.16.1"
	oidHrStorageUsed   = "1.3.6.1.2.1.25.2.3.1.6.1"
	oidHrStorageSize   = "1.3.6.1.2.1.25.2.3.1.5.1"
	oidHrStorageAlloc  = "1.3.6.1.2.1.25.2.3.1.4.1"
	oidHrMemUsed       = "1.3.6.1.2.1.25.2.3.1.6.2"
	oidHrMemTotal      = "1.3.6.1.2.1.25.2.3.1.5.2"
)

type SNMPCollector struct{}

func NewSNMPCollector() *SNMPCollector { return &SNMPCollector{} }

func (c *SNMPCollector) Collect(target SNMPTarget) (Metrics, error) {
	g := &gosnmp.GoSNMP{
		Target:    target.Host,
		Port:      uint16(target.Port),
		Community: target.Community,
		Version:   gosnmp.Version2c,
		Timeout:   5 * time.Second,
		Retries:   1,
	}
	start := time.Now()
	if err := g.Connect(); err != nil {
		return Metrics{ServiceUp: false}, fmt.Errorf("connect: %w", err)
	}
	defer g.Conn.Close()

	oids := []string{
		oidSysUptime, oidIfInOctets, oidIfOutOctets,
		oidHrStorageUsed, oidHrStorageSize, oidHrStorageAlloc,
		oidHrMemUsed, oidHrMemTotal,
	}
	result, err := g.Get(oids)
	latencyMs := int(time.Since(start).Milliseconds())
	if err != nil {
		return Metrics{ServiceUp: false, SNMPLatencyMs: latencyMs},
			fmt.Errorf("get: %w", err)
	}

	m := Metrics{ServiceUp: true, SNMPLatencyMs: latencyMs}
	for _, pdu := range result.Variables {
		val := gosnmp.ToBigInt(pdu.Value).Int64()
		switch pdu.Name {
		case "."+oidSysUptime:
			m.UptimeSeconds = val / 100 // timeticks → segundos
		case "."+oidHrMemUsed:
			m.RAMUsageMB = int(val / 1024)
		case "."+oidHrMemTotal:
			m.RAMTotalMB = int(val / 1024)
		}
	}
	// Disco: (used * allocUnit) / (size * allocUnit) * 100
	var used, size, alloc int64
	for _, pdu := range result.Variables {
		v := gosnmp.ToBigInt(pdu.Value).Int64()
		switch pdu.Name {
		case "."+oidHrStorageUsed:
			used = v
		case "."+oidHrStorageSize:
			size = v
		case "."+oidHrStorageAlloc:
			alloc = v
		}
	}
	if size > 0 && alloc > 0 {
		m.DiskUsagePercent = float64(used) / float64(size) * 100
	}
	return m, nil
}
```

- [ ] **Step 2: Implementar PostgresStorage**

Crear `go_collector/internal/storage/postgres_storage.go`:

```go
package storage

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

type PostgresStorage struct {
	db *sql.DB
}

func NewPostgresStorage(dsn string) (*PostgresStorage, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("open db: %w", err)
	}
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("ping db: %w", err)
	}
	return &PostgresStorage{db: db}, nil
}

func (s *PostgresStorage) GetServices() ([]MonitoredService, error) {
	rows, err := s.db.Query(
		`SELECT id, service_name, host_ip, snmp_port, 'public' AS community
		 FROM monitored_services WHERE enabled = true`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var services []MonitoredService
	for rows.Next() {
		var svc MonitoredService
		if err := rows.Scan(&svc.ID, &svc.Name, &svc.Host, &svc.SNMPPort, &svc.Community); err != nil {
			return nil, err
		}
		services = append(services, svc)
	}
	return services, rows.Err()
}

func (s *PostgresStorage) SaveMetric(r MetricRecord) error {
	_, err := s.db.Exec(`
		INSERT INTO metrics
			(service_id, cpu_usage_percent, ram_usage_mb, ram_total_mb,
			 disk_usage_percent, bandwidth_in_mb, bandwidth_out_mb,
			 uptime_seconds, service_status, snmp_latency_ms, collected_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
		r.ServiceID, r.CPUUsagePercent, r.RAMUsageMB, r.RAMTotalMB,
		r.DiskUsagePercent, r.BandwidthInMB, r.BandwidthOutMB,
		r.UptimeSeconds, r.ServiceStatus, r.SNMPLatencyMs, r.CollectedAt,
	)
	return err
}

func (s *PostgresStorage) ActiveEvent(serviceID string) (string, error) {
	var id string
	err := s.db.QueryRow(
		`SELECT id FROM service_events
		 WHERE service_id = $1 AND event_type = 'down' AND ended_at IS NULL
		 ORDER BY started_at DESC LIMIT 1`,
		serviceID,
	).Scan(&id)
	if err == sql.ErrNoRows {
		return "", nil
	}
	return id, err
}

func (s *PostgresStorage) RecordDown(serviceID string, cause string) (string, error) {
	// Idempotente: si ya hay un evento 'down' abierto no crea uno nuevo.
	existing, err := s.ActiveEvent(serviceID)
	if err != nil {
		return "", err
	}
	if existing != "" {
		return existing, nil
	}
	var id string
	err = s.db.QueryRow(
		`INSERT INTO service_events (service_id, event_type, started_at, cause)
		 VALUES ($1, 'down', now(), $2) RETURNING id`,
		serviceID, cause,
	).Scan(&id)
	return id, err
}

func (s *PostgresStorage) RecordRecovered(serviceID string, openEventID string) error {
	// Cerrar el evento 'down' existente.
	if openEventID != "" {
		_, err := s.db.Exec(
			`UPDATE service_events SET ended_at = now(), resolved = true
			 WHERE id = $1`,
			openEventID,
		)
		if err != nil {
			return err
		}
	}
	// Insertar evento 'recovered'.
	_, err := s.db.Exec(
		`INSERT INTO service_events (service_id, event_type, started_at, resolved)
		 VALUES ($1, 'recovered', now(), true)`,
		serviceID,
	)
	return err
}

func (s *PostgresStorage) Close() error { return s.db.Close() }
```

- [ ] **Step 3: Reescribir main.go**

El collector mantiene `activeEvents map[serviceID]eventID` en memoria para saber si ya abrió un evento de caída. Así detecta la transición online→offline (abre evento) y offline→online (cierra evento + crea 'recovered').

```go
package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/cuy-sentinel/collector/internal/collector"
	"github.com/cuy-sentinel/collector/internal/storage"
)

func main() {
	dsn := os.Getenv("PG_DSN")
	if dsn == "" {
		dsn = "postgres://app:app_secret_2025@localhost:5432/postgres?sslmode=disable"
	}
	intervalStr := os.Getenv("SNMP_INTERVAL")
	interval, _ := strconv.Atoi(intervalStr)
	if interval <= 0 {
		interval = 300
	}

	store, err := storage.NewPostgresStorage(dsn)
	if err != nil {
		log.Fatalf("storage: %v", err)
	}
	defer store.Close()

	col := collector.NewSNMPCollector()
	// activeEvents: serviceID → ID del service_events abierto (event_type='down')
	// Se sincroniza con la BD al arrancar consultando ActiveEvent por cada servicio.
	activeEvents := map[string]string{}

	log.Printf("collector started — polling every %ds", interval)

	for {
		services, err := store.GetServices()
		if err != nil {
			log.Printf("get services: %v", err)
			time.Sleep(time.Duration(interval) * time.Second)
			continue
		}

		for _, svc := range services {
			// Sincronizar estado de evento abierto al arrancar (survive restarts)
			if _, seen := activeEvents[svc.ID]; !seen {
				openID, err := store.ActiveEvent(svc.ID)
				if err != nil {
					log.Printf("active event %s: %v", svc.Name, err)
				}
				activeEvents[svc.ID] = openID // "" si no hay evento abierto
			}

			target := collector.SNMPTarget{
				ServiceID: svc.ID,
				Host:      svc.Host,
				Port:      svc.SNMPPort,
				Community: svc.Community,
			}
			m, collectErr := col.Collect(target)
			isDown := collectErr != nil || !m.ServiceUp
			status := "online"
			if isDown {
				status = "offline"
			}

			// ─── Transición online → offline: abrir service_event ───────
			if isDown && activeEvents[svc.ID] == "" {
				cause := "SNMP unreachable"
				if collectErr != nil {
					cause = collectErr.Error()
				}
				eventID, err := store.RecordDown(svc.ID, cause)
				if err != nil {
					log.Printf("record down %s: %v", svc.Name, err)
				} else {
					activeEvents[svc.ID] = eventID
					log.Printf("⚠ %s DOWN — event %s opened", svc.Name, eventID)
				}
			}

			// ─── Transición offline → online: cerrar service_event ──────
			if !isDown && activeEvents[svc.ID] != "" {
				if err := store.RecordRecovered(svc.ID, activeEvents[svc.ID]); err != nil {
					log.Printf("record recovered %s: %v", svc.Name, err)
				} else {
					log.Printf("✓ %s RECOVERED — event %s closed", svc.Name, activeEvents[svc.ID])
					activeEvents[svc.ID] = ""
				}
			}

			// ─── Guardar métrica en todos los casos ─────────────────────
			rec := storage.MetricRecord{
				ServiceID:        svc.ID,
				RAMUsageMB:       m.RAMUsageMB,
				RAMTotalMB:       m.RAMTotalMB,
				DiskUsagePercent: m.DiskUsagePercent,
				UptimeSeconds:    m.UptimeSeconds,
				ServiceStatus:    status,
				SNMPLatencyMs:    m.SNMPLatencyMs,
				CollectedAt:      time.Now(),
			}
			if saveErr := store.SaveMetric(rec); saveErr != nil {
				log.Printf("save metric %s: %v", svc.Name, saveErr)
			} else {
				fmt.Printf("✓ %s — %s\n", svc.Name, status)
			}
		}
		time.Sleep(time.Duration(interval) * time.Second)
	}
}
```

- [ ] **Step 4: Crear Dockerfile multi-stage**

Crear `go_collector/Dockerfile`:

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o collector .

FROM alpine:3.19
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /app/collector .
CMD ["./collector"]
```

- [ ] **Step 5: Compilar localmente para verificar**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend/go_collector
go build ./...
```

Expected: sin errores de compilación.

- [ ] **Step 6: Commit**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
git add go_collector/
git commit -m "feat: implement Go SNMP collector with PostgreSQL storage"
```

---

## Task 10: Demo de failover (smoke test)

Este task verifica que todo funciona y que el failover es visible en la demo.

- [ ] **Step 1: Levantar el stack completo**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
docker compose up -d --build
```

Expected: todos los servicios en estado `Up`. Patroni toma ~30s en elegir primary.

- [ ] **Step 2: Verificar health de Patroni**

```bash
# Nodo 1 es primary
curl http://localhost:8008/primary     # → 200 OK
curl http://localhost:8009/primary     # → 503

# Nodo 2 es replica
curl http://localhost:8009/replica     # → 200 OK
```

- [ ] **Step 3: Aplicar schema**

```bash
PGPASSWORD=app_secret_2025 psql \
  -h localhost -p 5432 -U app -d postgres \
  -f init/01_schema.sql
```

- [ ] **Step 4: Probar API login**

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"master@cuy.local","password":"sentinel2025"}'
```

Expected: `{"token":"eyJ...","user":{"role":"master",...}}`

- [ ] **Step 5: Simular failover para la demo**

```bash
# Matar el primary
docker compose stop patroni1

# Esperar ~15s y verificar que patroni2 tomó el rol de primary
sleep 15
curl http://localhost:8009/primary     # → 200 OK

# La API sigue respondiendo (HAProxy redirige a patroni2 automáticamente)
curl http://localhost:3000/health      # → {"status":"ok"}

# Recuperar patroni1 — vuelve como replica
docker compose start patroni1
```

- [ ] **Step 6: Verificar HAProxy stats**

Abrir en browser: `http://localhost:7000`
Verificar: en backend `pg_primary`, patroni1 muestra `DOWN` y patroni2 muestra `UP`.

- [ ] **Step 7: Commit final**

```bash
cd /Users/jairconislla/Projects/cuy_sentinel_backend
git add .
git commit -m "chore: final monorepo — ready for phase 2 demo"
```

---

## Notas para la presentación

- **Failover visible:** `docker compose stop patroni1` → esperar 15s → mostrar HAProxy stats en `:7000` → API sigue funcionando
- **Patroni elige primary vía etcd:** sin intervención manual, sin split-brain posible
- **HAProxy stats:** `http://localhost:7000` muestra en tiempo real qué nodo es primary
- **Socket.IO:** cuando el Go collector inserta una métrica, el trigger `pg_notify` dispara y Node.js hace broadcast a todos los clientes Flutter conectados
- **Arquitectura de industria:** esta es exactamente la misma arquitectura que usan equipos de producción (Zalando usa Patroni en producción para sus PostgreSQL clusters)
