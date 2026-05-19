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

## Pantallas

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/dashboard` | Dashboard | Stat cards, gráficas CPU/RAM/Disco/BW, estado de servicios, salud del recolector, eventos recientes |
| `/services` | Servicios | Detalle por servicio: métricas actuales, barras de progreso, info SNMP |
| `/metrics` | Métricas | Historial con selector de rango (1 h / 6 h / 24 h / 7 d) |
| `/alerts` | Alertas | Umbrales superados e historial de incidentes |
| `/users` | Usuarios | Lista de usuarios, estado online/offline, log de accesos |

---

## Instrucciones de despliegue

### 1. Prerrequisitos

| Herramienta | Versión mínima | Verificar |
|---|---|---|
| Flutter SDK | 3.x (`^3.11.5`) | `flutter --version` |
| Dart SDK | incluido con Flutter | `dart --version` |
| Git | cualquier versión reciente | `git --version` |

```sh
flutter doctor   # todos los checks relevantes deben estar en verde
```

### 2. Clonar e instalar dependencias

```sh
git clone https://github.com/<org>/cuy_sentinel.git
cd cuy_sentinel
flutter pub get
```

### 3. Puntos de entrada (`main_*.dart`)

El proyecto tiene cuatro entry points, uno por modo de ejecución:

| Archivo | Modo | Credenciales |
|---|---|---|
| `lib/main.dart` | Demo (datos locales) | No requiere |
| `lib/main_development.dart` | Demo explícito para desarrollo | No requiere |
| `lib/main_phase1.dart` | Fase 1 — Supabase en la nube | `envs/sentinel.phase1.json` |
| `lib/main_phase2.dart` | Fase 2 — API Node.js + Socket.IO | `envs/sentinel.phase2.json` |

### 4. Configurar variables de entorno

Las credenciales **no se versionan**. Se pasan en tiempo de compilación con `--dart-define-from-file`.

```sh
cp envs/sentinel.example.json envs/sentinel.phase1.json
# Editar sentinel.phase1.json con las credenciales de Supabase
```

```json
{
  "SUPABASE_URL": "https://<tu-proyecto>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-key>",
  "API_BASE_URL": "",
  "API_SECRET": ""
}
```

> Credenciales en el dashboard de Supabase: **Project Settings → API → Project URL / anon key**

### 5. Ejecutar en desarrollo

```sh
# Modo demo — sin credenciales
flutter run --target lib/main_development.dart

# Fase 1 — Supabase (requiere sentinel.phase1.json)
flutter run --target lib/main_phase1.dart \
            --dart-define-from-file=envs/sentinel.phase1.json

# Fase 1 en Chrome
flutter run -d chrome \
            --target lib/main_phase1.dart \
            --dart-define-from-file=envs/sentinel.phase1.json

# Fase 2 — Node.js API (requiere sentinel.phase2.json)
flutter run --target lib/main_phase2.dart \
            --dart-define-from-file=envs/sentinel.phase2.json
```

### 6. Construir para producción

#### Web

```sh
flutter build web \
    --target lib/main_phase1.dart \
    --dart-define-from-file=envs/sentinel.phase1.json
```

Resultado en `build/web/`. Servir con Nginx, Firebase Hosting, GitHub Pages, etc.

```sh
# Verificar localmente
cd build/web && python3 -m http.server 8080
```

#### Android

```sh
# APK
flutter build apk \
    --target lib/main_phase1.dart \
    --dart-define-from-file=envs/sentinel.phase1.json

# App Bundle (Play Store)
flutter build appbundle \
    --target lib/main_phase1.dart \
    --dart-define-from-file=envs/sentinel.phase1.json
```

#### macOS / Windows

```sh
flutter build macos \
    --target lib/main_phase1.dart \
    --dart-define-from-file=envs/sentinel.phase1.json

flutter build windows \
    --target lib/main_phase1.dart \
    --dart-define-from-file=envs/sentinel.phase1.json
```

### 7. Plataformas soportadas

| Plataforma | Soporte |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

---

## Ícono de lanzamiento y splash screen

El proyecto genera íconos nativos y splash screen a partir de los archivos en `assets/`:

| Plataforma | Fuente |
|---|---|
| Android / iOS | `assets/launcher.png` |
| Web | `assets/launcher_web.png` |
| macOS | `assets/launcher_macos.png` |
| Windows | `assets/launcher_windows.png` |
| Splash screen (todas) | `assets/logos/logo_stack_primary.png` |

Para regenerar íconos y splash después de cambiar las imágenes:

```sh
# Regenerar íconos de lanzamiento
dart run flutter_launcher_icons

# Regenerar splash screen
dart run flutter_native_splash:create
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

Ver `cuy_sentinel_go/database/schema.sql` para el DDL completo.

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `flutter: command not found` | Flutter no está en el PATH | Añadir `<flutter-dir>/bin` al PATH |
| Error de credenciales al iniciar | Archivo `.json` faltante o mal formado | Verificar `envs/sentinel.phase1.json` |
| Pantalla en blanco en web | CORS bloqueado por Supabase | Añadir el dominio en Supabase → Auth → URL Configuration |
| `flutter doctor` reporta errores de Xcode | Xcode sin licencia | `sudo xcode-select --switch /Applications/Xcode.app` |
| Compilación falla en Android | `JAVA_HOME` no configurado | Instalar Android Studio y configurar el Android SDK |

---

## Licencia

Este proyecto está bajo la licencia [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).  
© 2025 Jair Conislla Bocangel · Daniel Rojas Sanchez · Jheampierre Ralli Peralta
