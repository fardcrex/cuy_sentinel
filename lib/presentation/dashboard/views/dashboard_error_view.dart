import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DashboardErrorView extends StatelessWidget {
  const DashboardErrorView({super.key, required this.message, required this.source});

  final String message;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '[$source]',
            style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
