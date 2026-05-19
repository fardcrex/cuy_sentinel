import 'package:flutter/material.dart';

import '../../../widgets/service_detail_card.dart';
import '../service_model.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.model});

  final ServiceDetailModel model;

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      name: model.name,
      containerName: model.containerName,
      host: model.host,
      snmpPort: model.snmpPort,
      status: model.status,
      cpuPercent: model.cpuPercent,
      ramUsedMb: model.ramUsedMb,
      ramTotalMb: model.ramTotalMb,
      diskPercent: model.diskPercent,
      bwInMbps: model.bwInMbps,
      bwOutMbps: model.bwOutMbps,
      uptimeLabel: model.uptimeLabel,
      imagePath: model.imagePath,
      accentColor: model.accentColor,
    );
  }
}
