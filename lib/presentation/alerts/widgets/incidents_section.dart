import 'package:flutter/material.dart';

import '../../widgets/incident_record_tile.dart';
import '../alert_model.dart';
import 'empty_state.dart';

class IncidentsSection extends StatelessWidget {
  const IncidentsSection({super.key, required this.incidents});

  final List<IncidentModel> incidents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de incidentes',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
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
