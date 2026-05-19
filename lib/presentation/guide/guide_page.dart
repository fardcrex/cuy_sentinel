import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/guide_header.dart';
import 'widgets/guide_illustrations.dart';
import 'widgets/guide_screen_tab.dart';
import 'widgets/guide_summary_tab.dart';
import 'widgets/guide_tab_bar.dart';
import 'widgets/screen_miniature/alerts_miniature.dart';
import 'widgets/screen_miniature/dashboard_miniature.dart';
import 'widgets/screen_miniature/metrics_miniature.dart';
import 'widgets/screen_miniature/services_miniature.dart';
import 'widgets/screen_miniature/users_miniature.dart';

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
    screenPreview: DashboardMiniature(),
    description:
        'Vista principal del panel. Muestra el estado en tiempo real de ambos servicios con métricas resumidas, gráficos de rendimiento y últimos eventos del sistema.',
    cards: [
      GuideCardData(
        icon: Icons.grid_view_rounded,
        name: 'Tarjetas de estado (4 cards)',
        illustration: StatCardsIllustration(),
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
        illustration: ResourceChartIllustration(),
        body:
            'Gráfico de líneas con el historial de CPU (%), RAM (MB) y Disco (%) de ambos servicios. '
            'Cada métrica tiene su propio color. Permite ver picos de consumo recientes '
            'sin necesidad de ir a la pantalla de Métricas.',
      ),
      GuideCardData(
        icon: Icons.network_check_rounded,
        name: 'Gráfico de ancho de banda',
        illustration: BandwidthChartIllustration(),
        body:
            'Muestra el tráfico de red entrante y saliente en MB/s. '
            'Los chips Ambos / Passbolt / ChkMonitor filtran qué servicio se visualiza. '
            'El gráfico se desliza de derecha a izquierda con cada nueva lectura recibida '
            '(ventana deslizante sincronizada con el intervalo de recolección de 5 minutos).',
      ),
      GuideCardData(
        icon: Icons.cloud_done_rounded,
        name: 'Estado de servicios',
        illustration: ServiceStatusIllustration(),
        body:
            'Card que muestra si Passbolt y ChkMonitor están online, offline o degradados '
            'en este momento. Incluye IP, puerto SNMP y tiempo de actividad acumulado (uptime) '
            'de cada servicio.',
      ),
      GuideCardData(
        icon: Icons.health_and_safety_outlined,
        name: 'Salud del recolector',
        illustration: CollectorHealthIllustration(),
        body:
            'Indica si el agente Go que recolecta los datos SNMP está funcionando correctamente. '
            'Muestra cuándo fue su última ejecución, cuánto tardó y si tuvo errores. '
            'Si falla, los datos dejan de actualizarse aunque los servicios estén online.',
      ),
      GuideCardData(
        icon: Icons.timeline_rounded,
        name: 'Eventos recientes',
        illustration: RecentEventsIllustration(),
        body:
            'Lista de los últimos 3 eventos del sistema: caídas detectadas, recuperaciones '
            'y degradaciones de rendimiento. Cada evento muestra el servicio afectado, '
            'la fecha/hora y una descripción breve de lo ocurrido.',
      ),
    ],
  );

  Widget _serviciosTab() => const GuideScreenTab(
    title: 'Servicios',
    screenPreview: ServicesMiniature(),
    description:
        'Detalle de los servicios monitoreados y la infraestructura de base de datos. '
        'Se divide en dos sub-tabs: Servicios y Bases de datos.',
    cards: [
      GuideCardData(
        icon: Icons.dns_rounded,
        name: 'Sub-tab Servicios — Cards de servicio',
        illustration: ServiceCardsIllustration(),
        body:
            'Una card por servicio monitoreado (Passbolt y ChkMonitor) mostradas side by side. '
            'Cada card muestra: estado actual (online / offline / degradado), '
            'IP y puerto SNMP, tiempo de uptime acumulado y versión si está disponible. '
            'Los dos servicios aparecen en paralelo para comparación directa.',
      ),
      GuideCardData(
        icon: Icons.storage_rounded,
        name: 'Sub-tab Servicios — Card de infraestructura',
        illustration: InfraCardIllustration(),
        body:
            'Descripción del entorno Docker donde corren los servicios: '
            'configuración de red, volúmenes montados y estructura general de contenedores. '
            'Aparece debajo de las cards de servicio, a ancho completo.',
      ),
      GuideCardData(
        icon: Icons.cloud_outlined,
        name: 'Sub-tab Bases de datos — Supabase (Fase 1)',
        illustration: SupabaseCardIllustration(),
        body:
            'Card principal (izquierda, mayor tamaño) con el estado de la conexión a Supabase: '
            'tablas activas, URL del proyecto y estado del servicio. '
            'Es la base de datos actualmente en uso en Fase 1. '
            'Marcada con la píldora "1 activa".',
      ),
      GuideCardData(
        icon: Icons.table_chart_outlined,
        name: 'Sub-tab Bases de datos — Schema',
        illustration: SchemaCardIllustration(),
        body:
            'Resumen visual de las tablas del sistema: users, monitored_services, metrics, '
            'service_events y collector_runs. Muestra las relaciones principales y '
            'el propósito de cada tabla.',
      ),
      GuideCardData(
        icon: Icons.storage_outlined,
        name: 'Sub-tab Bases de datos — PostgreSQL Fase 2',
        illustration: Phase2DbIllustration(),
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
    screenPreview: MetricsMiniature(),
    description:
        'Histórico de métricas con filtro temporal. Permite analizar el comportamiento '
        'de cada servicio en un rango de tiempo específico, con gráficos y estadísticas agregadas.',
    cards: [
      GuideCardData(
        icon: Icons.tune_rounded,
        name: 'Fila de filtros',
        illustration: MetricsFiltersIllustration(),
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
        illustration: MetricsSummaryIllustration(),
        body:
            'Cuatro cards con estadísticas agregadas del período seleccionado: '
            'CPU (%), RAM (MB), Disco (%) y Latencia SNMP (ms). '
            'Cada card muestra el mínimo, promedio y máximo del período. '
            'El servicio mostrado depende del filtro seleccionado.',
      ),
      GuideCardData(
        icon: Icons.memory_rounded,
        name: 'Gráfico de recursos (histórico)',
        illustration: ResourceChartIllustration(),
        body:
            'Gráfico de líneas multi-serie con el historial de CPU, RAM y Disco '
            'en el rango seleccionado. Muestra gaps (espacios vacíos) si no hubo '
            'datos en algún intervalo de tiempo.',
      ),
      GuideCardData(
        icon: Icons.show_chart_rounded,
        name: 'Gráfico de ancho de banda (histórico)',
        illustration: BandwidthChartIllustration(),
        body:
            'Tráfico entrante y saliente en MB/s para el servicio y rango seleccionados. '
            'A diferencia del dashboard (tiempo real), aquí los datos son históricos '
            'agrupados en buckets de tiempo.',
      ),
      GuideCardData(
        icon: Icons.schedule_rounded,
        name: 'Uptime timeline',
        illustration: UptimeTimelineIllustration(),
        body:
            'Línea de tiempo visual del período mostrando cuándo el servicio estuvo online '
            '(verde) y offline o sin datos (rojo / vacío). '
            'Permite ver de un vistazo los períodos de caída en el rango analizado.',
      ),
      GuideCardData(
        icon: Icons.wifi_tethering_rounded,
        name: 'Salud SNMP',
        illustration: SnmpHealthIllustration(),
        body:
            'Latencia de respuesta SNMP en ms y porcentaje de pérdida de paquetes '
            'en el período seleccionado. Indica qué tan estable fue la comunicación '
            'SNMP con el servicio — valores altos indican problemas de red o sobrecarga.',
      ),
    ],
  );

  Widget _alertasTab() => const GuideScreenTab(
    title: 'Alertas',
    screenPreview: AlertsMiniature(),
    description:
        'Centro de alertas activas e historial de incidentes. Las alertas se generan '
        'automáticamente cuando una métrica SNMP supera los umbrales configurados.',
    cards: [
      GuideCardData(
        icon: Icons.summarize_outlined,
        name: 'Badges de resumen',
        illustration: AlertBadgesIllustration(),
        body:
            'Tres contadores en el header: total de alertas activas, cuántas son críticas '
            '(rojo) y cuántas son advertencias (ámbar). '
            'Permiten ver el estado global de alertas de un vistazo sin necesidad de leer la lista.',
      ),
      GuideCardData(
        icon: Icons.notifications_active_rounded,
        name: 'Lista de alertas activas',
        illustration: AlertListIllustration(),
        body:
            'Cada alerta muestra: severidad indicada por el color del borde izquierdo '
            '(rojo = crítico, ámbar = advertencia), servicio afectado, '
            'métrica que la generó (ej: CPU > 80%), valor actual y '
            'tiempo transcurrido desde que se activó.',
      ),
      GuideCardData(
        icon: Icons.history_rounded,
        name: 'Sección de incidentes',
        illustration: IncidentsIllustration(),
        body:
            'Historial de incidentes ya resueltos: caídas de servicios o períodos de '
            'degradación que ya terminaron. Cada incidente muestra la causa, '
            'cuánto duró y cuándo se resolvió.',
      ),
      GuideCardData(
        icon: Icons.rule_rounded,
        name: 'Umbrales configurados',
        illustration: ThresholdsIllustration(),
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
    screenPreview: UsersMiniature(),
    description:
        'Gestión de usuarios del panel. Muestra quién tiene acceso al sistema, '
        'sus roles asignados y su actividad reciente de sesión.',
    cards: [
      GuideCardData(
        icon: Icons.people_outline_rounded,
        name: 'Badge de usuarios en línea',
        illustration: OnlineBadgeIllustration(),
        body:
            'Indicador en el header que muestra cuántos usuarios tienen una sesión activa '
            'en el panel en este momento.',
      ),
      GuideCardData(
        icon: Icons.manage_accounts_outlined,
        name: 'Lista de usuarios',
        illustration: UserListIllustration(),
        body:
            'Tabla principal (izquierda en desktop) con todos los usuarios registrados: '
            'nombre, email, rol (Admin o Viewer), estado de sesión actual '
            'y fecha/hora de última actividad.',
      ),
      GuideCardData(
        icon: Icons.analytics_outlined,
        name: 'Estadísticas de sesión',
        illustration: SessionStatsIllustration(),
        body:
            'Resumen de actividad: total de logins en el período, '
            'duración promedio de sesión y horarios de mayor actividad. '
            'Aparece en la columna derecha en desktop.',
      ),
      GuideCardData(
        icon: Icons.fact_check_outlined,
        name: 'Log de acceso',
        illustration: AccessLogIllustration(),
        body:
            'Historial de los últimos accesos al panel: '
            'qué usuario entró, cuándo y qué acción realizó '
            '(login, logout, cambio de contraseña). '
            'Aparece debajo de estadísticas de sesión en desktop.',
      ),
    ],
  );
}
