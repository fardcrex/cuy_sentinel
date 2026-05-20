import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../core/widgets/alert_notification_dialog.dart';
import '../../core/widgets/alert_toast_stack.dart';
import '../../feature/alerts/domain/entities/alert_event.dart';
import '../../feature/alerts/domain/entities/alert_severity.dart';
import '../../core/widgets/reconnecting_banner.dart';

// ─── Mock events (para dialogs y toasts locales) ──────────────────────────────

AlertEvent _mock(AlertSeverity severity) => switch (severity) {
  AlertSeverity.nuclear => AlertEvent(
    id: 'prev-nuclear',
    serviceId: 'svc-passbolt',
    serviceName: 'Passbolt',
    metricName: 'Intrusión de Sistema',
    currentValue: 9999,
    thresholdValue: 0,
    severity: AlertSeverity.nuclear,
    triggeredAt: DateTime.now(),
  ),
  AlertSeverity.critical => AlertEvent(
    id: 'prev-critical',
    serviceId: 'svc-passbolt',
    serviceName: 'Passbolt',
    metricName: 'CPU',
    currentValue: 83.2,
    thresholdValue: 80,
    severity: AlertSeverity.critical,
    triggeredAt: DateTime.now(),
  ),
  AlertSeverity.warning => AlertEvent(
    id: 'prev-warning',
    serviceId: 'svc-chkmonitor',
    serviceName: 'ChkMonitor',
    metricName: 'Uso de disco',
    currentValue: 73,
    thresholdValue: 70,
    severity: AlertSeverity.warning,
    triggeredAt: DateTime.now(),
  ),
  AlertSeverity.info => AlertEvent(
    id: 'prev-info',
    serviceId: 'svc-chkmonitor',
    serviceName: 'ChkMonitor',
    metricName: 'Latencia SNMP',
    currentValue: 145,
    thresholdValue: 200,
    severity: AlertSeverity.info,
    triggeredAt: DateTime.now(),
  ),
};

const _severities = [
  AlertSeverity.nuclear,
  AlertSeverity.critical,
  AlertSeverity.warning,
  AlertSeverity.info,
];

// ─── DB payload por severidad ─────────────────────────────────────────────────

const _dbService = {
  AlertSeverity.nuclear: 'Passbolt',
  AlertSeverity.critical: 'Passbolt',
  AlertSeverity.warning: 'ChkMonitor',
  AlertSeverity.info: 'ChkMonitor',
};

const _dbMetric = {
  AlertSeverity.nuclear: 'Intrusión de Sistema',
  AlertSeverity.critical: 'cpu_usage_percent',
  AlertSeverity.warning: 'disk_usage_percent',
  AlertSeverity.info: 'snmp_latency_ms',
};

const _dbCurrentValue = {
  AlertSeverity.nuclear: 9999.0,
  AlertSeverity.critical: 83.2,
  AlertSeverity.warning: 73.0,
  AlertSeverity.info: 145.0,
};

const _dbThresholdValue = {
  AlertSeverity.nuclear: 0.0,
  AlertSeverity.critical: 80.0,
  AlertSeverity.warning: 70.0,
  AlertSeverity.info: 200.0,
};

// ─── Page ─────────────────────────────────────────────────────────────────────

class AlertPreviewPage extends StatelessWidget {
  const AlertPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title: const Text(
          'Preview — Alertas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.stroke),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Banner reconexión ────────────────────────────────────────────
          const _SectionLabel(label: 'Banner de reconexión'),
          const SizedBox(height: 10),
          const _BannerPreviewSection(),
          SizedBox(height: 32),
          Divider(color: AppColors.stroke),
          SizedBox(height: 24),
          // ── Dialogs locales ──────────────────────────────────────────────
          _SectionLabel(label: 'Abrir dialog'),
          SizedBox(height: 10),
          _TriggerRow(),
          SizedBox(height: 32),
          Divider(color: AppColors.stroke),
          SizedBox(height: 24),
          // ── Enviar a Supabase ────────────────────────────────────────────
          _SectionLabel(label: 'Registrar en Supabase (en vivo)'),
          SizedBox(height: 10),
          _LiveAlertSection(),
        ],
      ),
    );
  }
}

// ─── Banner preview ───────────────────────────────────────────────────────────

class _BannerPreviewSection extends StatefulWidget {
  const _BannerPreviewSection();

  @override
  State<_BannerPreviewSection> createState() => _BannerPreviewSectionState();
}

class _BannerPreviewSectionState extends State<_BannerPreviewSection> {
  bool _showing = false;
  int _seconds = 8;
  late final _timer = Stream.periodic(const Duration(seconds: 1));
  late final _sub = _timer.listen((_) {
    if (!_showing) return;
    setState(() {
      if (_seconds > 0) {
        _seconds--;
      } else {
        _showing = false;
        _seconds = 8;
      }
    });
  });

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showing) ReconnectingBanner(secondsLeft: _seconds),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _showing = true;
            _seconds = 8;
          }),
          icon: const Icon(Icons.wifi_off_rounded, size: 15),
          label: const Text('Simular reconexión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warningAmber,
            side: BorderSide(
              color: AppColors.warningAmber.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─── Dialog trigger row ───────────────────────────────────────────────────────

class _TriggerRow extends StatelessWidget {
  const _TriggerRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final severity in _severities)
          _TriggerButton(severity: severity),
      ],
    );
  }
}

class _TriggerButton extends StatelessWidget {
  const _TriggerButton({required this.severity});
  final AlertSeverity severity;

  String get _label => switch (severity) {
    AlertSeverity.nuclear => 'Nuclear',
    AlertSeverity.critical => 'Crítico',
    AlertSeverity.warning => 'Advertencia',
    AlertSeverity.info => 'Info',
  };

  Color get _color => switch (severity) {
    AlertSeverity.nuclear => const Color(0xFFFF0040),
    AlertSeverity.critical => AppColors.danger,
    AlertSeverity.warning => AppColors.warning,
    AlertSeverity.info => AppColors.primary,
  };

  IconData get _icon => switch (severity) {
    AlertSeverity.nuclear => Icons.crisis_alert_rounded,
    AlertSeverity.critical => Icons.error_rounded,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.info => Icons.info_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final event = _mock(severity);
    return OutlinedButton.icon(
      onPressed: () {
        showAlertNotificationDialog(context, event);
        AlertToastStack.add(Overlay.of(context), event);
      },
      icon: Icon(_icon, size: 15),
      label: Text(_label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Live Supabase buttons ────────────────────────────────────────────────────

class _LiveAlertSection extends StatefulWidget {
  const _LiveAlertSection();

  @override
  State<_LiveAlertSection> createState() => _LiveAlertSectionState();
}

class _LiveAlertSectionState extends State<_LiveAlertSection> {
  Map<String, String> _serviceIds = {};
  final _sending = <AlertSeverity>{};

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final rows = await Supabase.instance.client
          .from('monitored_services')
          .select('id, service_name');
      if (mounted) {
        setState(() {
          _serviceIds = {
            for (final r in rows as List)
              r['service_name'] as String: r['id'] as String,
          };
        });
      }
    } catch (_) {
      // Demo mode — no Supabase, handled per button press
    }
  }

  Future<void> _send(AlertSeverity severity) async {
    if (_sending.contains(severity)) return;
    setState(() => _sending.add(severity));

    final serviceName = _dbService[severity]!;
    final serviceId = _serviceIds[serviceName];

    if (serviceId == null) {
      if (mounted) {
        AppToast.error(
          context,
          'Sin conexión a Supabase',
          detail: 'Ejecuta con --target lib/main_phase1.dart',
        );
        setState(() => _sending.remove(severity));
      }
      return;
    }

    try {
      // Nuclear no tiene valor en el CHECK de alert_thresholds.severity,
      // pero alert_events.severity no tiene CHECK — se puede insertar cualquier texto.
      await Supabase.instance.client.from('alert_events').insert({
        'service_id': serviceId,
        'service_name': serviceName,
        'metric_name': _dbMetric[severity],
        'current_value': _dbCurrentValue[severity],
        'threshold_value': _dbThresholdValue[severity],
        'severity': severity.name,
        'resolved': false,
      });
      if (mounted) {
        AppToast.success(
          context,
          'Alerta registrada',
          detail: '$serviceName · ${_dbMetric[severity]}',
        );
      }
    } catch (e) {
      if (mounted) {
        final isRls = e.toString().toLowerCase().contains('rls') ||
            e.toString().contains('42501') ||
            e.toString().toLowerCase().contains('row-level security') ||
            e.toString().toLowerCase().contains('permission denied');
        AppToast.error(
          context,
          isRls ? 'RLS bloqueó el insert' : 'Error al insertar',
          detail: isRls
              ? 'Crea la policy INSERT en alert_events en el SQL editor'
              : e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _sending.remove(severity));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final severity in _severities) ...[
          _LiveButton(
            severity: severity,
            serviceName: _dbService[severity]!,
            metric: _dbMetric[severity]!,
            currentValue: _dbCurrentValue[severity]!,
            thresholdValue: _dbThresholdValue[severity]!,
            isLoading: _sending.contains(severity),
            onTap: () => _send(severity),
          ),
          if (severity != _severities.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ─── Live button ──────────────────────────────────────────────────────────────

class _LiveButton extends StatelessWidget {
  const _LiveButton({
    required this.severity,
    required this.serviceName,
    required this.metric,
    required this.currentValue,
    required this.thresholdValue,
    required this.isLoading,
    required this.onTap,
  });

  final AlertSeverity severity;
  final String serviceName;
  final String metric;
  final double currentValue;
  final double thresholdValue;
  final bool isLoading;
  final VoidCallback onTap;

  Color get _accent => switch (severity) {
    AlertSeverity.nuclear => const Color(0xFFFF0040),
    AlertSeverity.critical => AppColors.danger,
    AlertSeverity.warning => AppColors.warning,
    AlertSeverity.info => AppColors.primary,
  };

  String get _label => switch (severity) {
    AlertSeverity.nuclear => 'Nuclear',
    AlertSeverity.critical => 'Crítico',
    AlertSeverity.warning => 'Advertencia',
    AlertSeverity.info => 'Info',
  };

  IconData get _icon => switch (severity) {
    AlertSeverity.nuclear => Icons.crisis_alert_rounded,
    AlertSeverity.critical => Icons.error_rounded,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.info => Icons.info_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.30)),
          ),
          child: Row(
            children: [
              Icon(_icon, color: accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$serviceName · $metric · $currentValue > $thresholdValue',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enviar',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.send_rounded, color: accent, size: 14),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
