import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../metric_model.dart';

class MetricsSnmpHealthCard extends StatelessWidget {
  const MetricsSnmpHealthCard({super.key, required this.rows});

  final List<MetricsSnmpRowModel> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salud SNMP',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            rows.length,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i < rows.length - 1 ? 12 : 0),
              child: MetricsSnmpRow(model: rows[i]),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.stroke, height: 1),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conectividad estable · sin pérdida de paquetes',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricsSnmpRow extends StatelessWidget {
  const MetricsSnmpRow({super.key, required this.model});

  final MetricsSnmpRowModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: model.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: model.color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: model.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              model.label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          MetricStatPill(
            label: 'Latencia',
            value: model.latency,
            color: model.color,
          ),
          const SizedBox(width: 8),
          MetricStatPill(
            label: 'Pérdida',
            value: model.loss,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class MetricStatPill extends StatelessWidget {
  const MetricStatPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final Widget value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
          child: value,
        ),
      ],
    );
  }
}
