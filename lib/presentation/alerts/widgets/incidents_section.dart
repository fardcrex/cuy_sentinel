import 'package:flutter/material.dart';

import '../../widgets/incident_record_tile.dart';
import '../alert_model.dart';
import 'empty_state.dart';

class IncidentsSection extends StatelessWidget {
  const IncidentsSection({
    super.key,
    required this.incidents,
    this.isRefreshing = false,
    this.onRefresh,
  });

  final List<IncidentModel> incidents;
  final bool isRefreshing;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Historial de incidentes',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (isRefreshing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar historial',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (incidents.isEmpty)
          const AlertEmptyState(message: 'Sin incidentes registrados')
        else
          ...List.generate(incidents.length, (index) {
            final incident = incidents[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < incidents.length - 1 ? 12 : 0,
              ),
              child: IncidentRecordTile(
                service: incident.service,
                type: incident.type,
                startTime: incident.startTime,
                endTime: incident.endTime,
                duration: incident.duration,
                cause: incident.cause,
              ),
            );
          }),
      ],
    );
  }
}
