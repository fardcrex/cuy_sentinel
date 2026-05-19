import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AlertEmptyState extends StatelessWidget {
  const AlertEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
