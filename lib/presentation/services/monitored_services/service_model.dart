import 'package:flutter/widgets.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../feature/metrics/domain/entities/metric.dart';
import '../../../feature/monitoring/domain/entities/monitored_service.dart';
import '../../../feature/monitoring/domain/entities/service_event.dart';
import '../../../feature/monitoring/domain/entities/service_status.dart';
import '../../metrics/cubit/metrics_state.dart';

// ── private helpers ───────────────────────────────────────────────────────────

String _formatUptime(int? seconds) {
  if (seconds == null) return '—';
  final d = Duration(seconds: seconds);
  if (d.inDays > 0) {
    final h = d.inHours.remainder(24);
    return '${d.inDays}d ${h}h';
  }
  if (d.inHours > 0) {
    final m = d.inMinutes.remainder(60);
    return '${d.inHours}h ${m}m';
  }
  return '${d.inMinutes}m';
}

Color _accentColor(String serviceId) => switch (serviceId.toLowerCase()) {
  'passbolt' => AppColors.primary,
  'chkmonitor' => AppColors.secondary,
  _ => AppColors.primary,
};

String _imagePath(String serviceId) => switch (serviceId.toLowerCase()) {
  'passbolt' => AppAssets.badgePassboltSuccess,
  'chkmonitor' => AppAssets.badgeServerSuccess,
  _ => AppAssets.badgeServerSuccess,
};

// ── models ────────────────────────────────────────────────────────────────────

/// UI-ready data for [ServiceDetailCard].
class ServiceDetailModel {
  ServiceDetailModel({
    required this.name,
    required this.containerName,
    required this.host,
    required this.snmpPort,
    required this.status,
    required this.cpuPercent,
    required this.ramUsedMb,
    required this.ramTotalMb,
    required this.diskPercent,
    required this.bwInMbps,
    required this.bwOutMbps,
    required this.uptimeLabel,
    required this.imagePath,
    required this.accentColor,
  });

  final String name;
  final String containerName;
  final String host;
  final int snmpPort;
  final ServiceStatus status;
  final double cpuPercent;
  final int ramUsedMb;
  final int ramTotalMb;
  final double diskPercent;
  final double bwInMbps;
  final double bwOutMbps;
  final String uptimeLabel;
  final String imagePath;
  final Color accentColor;
}

/// Online count label for the services header badge.
class ServicesSummaryModel {
  ServicesSummaryModel({required this.onlineLabel});

  final String onlineLabel;
}

// ── extensions ────────────────────────────────────────────────────────────────

extension ServiceDetailModelX on MonitoredService {
  ServiceDetailModel toModel(
    Metric? latest, {
    List<ServiceEvent> activeEvents = const [],
  }) {
    // An active event always wins over a stale metric — the backend emits
    // service events immediately when status changes, whereas metrics arrive
    // only every ~5 min from the Go collector.
    final activeEvent = activeEvents
        .where((e) => e.serviceId == id && e.isActive)
        .firstOrNull;

    final status = activeEvent != null
        ? switch (activeEvent.eventType) {
            ServiceEventType.down => ServiceStatus.offline,
            ServiceEventType.degraded => ServiceStatus.degraded,
            _ => latest?.serviceStatus ?? ServiceStatus.offline,
          }
        : latest?.serviceStatus ?? ServiceStatus.offline;

    return ServiceDetailModel(
      name: serviceName,
      containerName: containerName,
      host: hostIp,
      snmpPort: snmpPort,
      status: status,
      cpuPercent: latest?.cpuUsagePercent ?? 0,
      ramUsedMb: latest?.ramUsageMb ?? 0,
      ramTotalMb: latest?.ramTotalMb ?? 1,
      diskPercent: latest?.diskUsagePercent ?? 0,
      bwInMbps: latest?.bandwidthInMb ?? 0,
      bwOutMbps: latest?.bandwidthOutMb ?? 0,
      uptimeLabel: _formatUptime(latest?.uptimeSeconds),
      imagePath: _imagePath(serviceName),
      accentColor: _accentColor(serviceName),
    );
  }
}

extension ServicesSummaryModelX on MetricsLoaded {
  ServicesSummaryModel toSummaryModel() {
    var online = 0;
    if (passboltMetrics.isNotEmpty &&
        passboltMetrics.first.serviceStatus == ServiceStatus.online) {
      online++;
    }
    if (chkmonitorMetrics.isNotEmpty &&
        chkmonitorMetrics.first.serviceStatus == ServiceStatus.online) {
      online++;
    }
    return ServicesSummaryModel(onlineLabel: '$online en línea');
  }
}
