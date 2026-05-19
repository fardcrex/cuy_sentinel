import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AlertsErrorView extends StatelessWidget {
  const AlertsErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.danger),
      ),
    );
  }
}
