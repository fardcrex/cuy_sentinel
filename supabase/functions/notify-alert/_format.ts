import type { AlertRecord } from './_types.ts';

const SEVERITY_EMOJI: Readonly<Record<string, string>> = {
  nuclear: '☢️',
  critical: '🔴',
  warning: '🟡',
  info: '🔵',
};

const METRIC_LABEL: Readonly<Record<string, string>> = {
  cpu_usage_percent: 'CPU',
  ram_usage_mb: 'RAM',
  disk_usage_percent: 'Disco',
  bandwidth_in_mb: 'Ancho de banda (entrada)',
  bandwidth_out_mb: 'Ancho de banda (salida)',
  snmp_latency_ms: 'Latencia SNMP',
};

export function formatAlertMessage(alert: AlertRecord): string {
  const emoji = SEVERITY_EMOJI[alert.severity] ?? '⚠️';
  const metricLabel = METRIC_LABEL[alert.metric_name] ?? alert.metric_name;
  const triggeredAt = new Date(alert.triggered_at).toLocaleString('es-PE', {
    timeZone: 'America/Lima',
    hour12: false,
  });

  return [
    `${emoji} *Alerta ${alert.severity.toUpperCase()}* — ${alert.service_name}`,
    ``,
    `📊 *Métrica:* ${metricLabel}`,
    `📈 *Valor actual:* ${alert.current_value}`,
    `🚧 *Umbral:* ${alert.threshold_value}`,
    `🕒 *Hora:* ${triggeredAt}`,
  ].join('\n');
}
