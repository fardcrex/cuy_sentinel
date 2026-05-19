import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class GuideHeader extends StatelessWidget {
  const GuideHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.stroke)),
      ),
      child: Row(
        children: [
          Image.asset(AppAssets.logoHorizontalPrimary, height: 32),
          const SizedBox(width: 12),
          Text(
            'Guía del Panel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
              ),
            ),
            child: const Text(
              'USO INTERNO',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Spacer(),
          Tooltip(
            message: 'Próximamente',
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.science_outlined, size: 15),
              label: const Text('Ver guía técnica →'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textInactive,
                side: const BorderSide(color: AppColors.stroke),
                textStyle: const TextStyle(fontSize: 13),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
