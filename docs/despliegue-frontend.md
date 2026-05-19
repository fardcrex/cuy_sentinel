# Despliegue — Cuy Sentinel (Panel Flutter)

Panel de monitoreo externo multiplataforma para infraestructura dockerizada vía SNMP.

**Proyecto:** Programación de Interfaces y Dispositivos Periféricos  
**Docente:** Prof. Rene Alejandro Zamudio Ariza  
**Equipo:** Jair Conislla Bocangel · Daniel Rojas Sanchez · Jheampierre Ralli Peralta

---

## 1. Prerrequisitos

| Herramienta | Versión mínima | Verificar con |
|---|---|---|
| Flutter SDK | 3.x (SDK `^3.11.5`) | `flutter --version` |
| Dart SDK | incluido con Flutter | `dart --version` |
| Git | cualquier versión reciente | `git --version` |
| Editor | VS Code o Android Studio | — |

Para instalar Flutter: <https://docs.flutter.dev/get-started/install>

Confirmar que el entorno esté listo:

```sh
flutter doctor
```

Todos los checks relevantes a la plataforma objetivo deben aparecer en verde.

---

## 2. Obtener el código fuente

```sh
git clone https://github.com/<org>/cuy_sentinel.git
cd cuy_sentinel
```

---

## 3. Instalar dependencias

```sh
flutter pub get
```

Esto descarga todos los paquetes declarados en `pubspec.yaml`:
- `flutter_bloc` — gestión de estado
- `go_router` — navegación declarativa
- `supabase_flutter` — cliente Supabase (Fase 1)
- `google_fonts` — tipografía

---

## 4. Configurar variables de entorno

Las credenciales **no se versiones** en el repositorio. Se pasan en tiempo de compilación con `--dart-define-from-file`.

### Fase 1 — Supabase (activa)

```sh
cp envs/sentinel.example.json envs/sentinel.phase1.json
```

Editar `envs/sentinel.phase1.json` con las credenciales del proyecto Supabase:

```json
{
  "SUPABASE_URL": "https://<tu-proyecto>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-key>",
  "API_BASE_URL": "",
  "API_SECRET": ""
}
```

> Las credenciales se obtienen en el dashboard de Supabase:  
> **Project Settings → API → Project URL / anon key**

### Modo demo (sin credenciales)

El proyecto corre sin ninguna credencial usando datos sembrados localmente. No se requiere ningún archivo de entorno.

---

## 5. Ejecutar en desarrollo

### Modo demo — sin credenciales

```sh
flutter run
```

Levanta la app con datos de prueba generados localmente. Ideal para revisar la UI sin necesitar acceso a Supabase.

### Fase 1 — conectado a Supabase

```sh
# En el dispositivo/emulador conectado
flutter run --dart-define-from-file=envs/sentinel.phase1.json

# En Chrome (web)
flutter run -d chrome --dart-define-from-file=envs/sentinel.phase1.json
```

---

## 6. Construir para producción

### Web

```sh
flutter build web --dart-define-from-file=envs/sentinel.phase1.json
```

El resultado queda en `build/web/`. Se puede servir con cualquier servidor estático (Nginx, Apache, GitHub Pages, Firebase Hosting, etc.).

**Servir localmente para verificar:**

```sh
cd build/web
python3 -m http.server 8080
# Abrir http://localhost:8080
```

### Android (APK)

```sh
flutter build apk --dart-define-from-file=envs/sentinel.phase1.json
```

APK generado en `build/app/outputs/flutter-apk/app-release.apk`.

### Android (App Bundle para Play Store)

```sh
flutter build appbundle --dart-define-from-file=envs/sentinel.phase1.json
```

### macOS

```sh
flutter build macos --dart-define-from-file=envs/sentinel.phase1.json
```

### Windows

```sh
flutter build windows --dart-define-from-file=envs/sentinel.phase1.json
```

---

## 7. Plataformas soportadas

| Plataforma | Soporte |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Web (Chrome, Edge, Firefox) | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

---

## 8. Estructura relevante del repositorio

```
cuy_sentinel/
├── envs/
│   ├── sentinel.example.json   # Plantilla de credenciales (versionada)
│   ├── sentinel.phase1.json    # Credenciales Supabase (NO versionar)
│   └── sentinel.phase2.json    # Credenciales Fase 2 (NO versionar)
├── lib/
│   ├── core/                   # Env, tema, navegación, responsivo
│   ├── feature/                # Dominio y casos de uso
│   └── presentation/           # Páginas y widgets
├── assets/                     # Logos, íconos, ilustraciones
└── docs/
    └── despliegue-frontend.md  # Este documento
```

---

## 9. Pantallas del panel

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/dashboard` | Dashboard | Resumen general: stat cards, gráficas, estado de servicios |
| `/services` | Servicios | Detalle por servicio: métricas, barras de progreso, info SNMP |
| `/metrics` | Métricas | Historial con selector de rango (1 h / 6 h / 24 h / 7 d) |
| `/alerts` | Alertas | Umbrales superados e historial de incidentes |
| `/users` | Usuarios | Lista de usuarios y log de accesos |

---

## 10. Solución de problemas frecuentes

| Síntoma | Causa probable | Solución |
|---|---|---|
| `flutter: command not found` | Flutter no está en el PATH | Añadir `<flutter-dir>/bin` al PATH |
| Error de credenciales al iniciar | Archivo `.json` incorrecto o faltante | Verificar `envs/sentinel.phase1.json` |
| Pantalla en blanco en web | CORS bloqueado por Supabase | Añadir el dominio en Supabase → Auth → URL Configuration |
| `flutter doctor` reporta errores de Xcode | Xcode no instalado o sin licencia | `sudo xcode-select --switch /Applications/Xcode.app` |
| Compilación falla en Android | `JAVA_HOME` no configurado | Instalar Android Studio y configurar el SDK de Android |
