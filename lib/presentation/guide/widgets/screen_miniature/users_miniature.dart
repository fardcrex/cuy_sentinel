import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class UsersMiniature extends StatelessWidget {
  const UsersMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '2 online',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _UserRow(color: AppColors.primary),
                      const SizedBox(height: 4),
                      _UserRow(color: AppColors.textSecondary),
                      const SizedBox(height: 4),
                      _UserRow(color: AppColors.primary),
                      const SizedBox(height: 4),
                      _UserRow(color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: MiniBox(accentColor: AppColors.primaryBright),
                      ),
                      const SizedBox(height: 4),
                      const Expanded(child: MiniBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 2,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 3),
              Container(
                width: 24,
                height: 2,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
