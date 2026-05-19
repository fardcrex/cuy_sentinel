import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AlertsMiniature extends StatelessWidget {
  const AlertsMiniature({super.key});

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
          Row(
            children: [
              _Badge(color: AppColors.danger, label: '●2'),
              const SizedBox(width: 4),
              _Badge(color: AppColors.warning, label: '●3'),
              const SizedBox(width: 4),
              _Badge(color: AppColors.textSecondary, label: '5'),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _AlertItem(color: AppColors.danger),
                      const SizedBox(height: 3),
                      _AlertItem(color: AppColors.warning),
                      const SizedBox(height: 3),
                      _AlertItem(color: AppColors.warning),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: AppColors.stroke,
                      ),
                      const SizedBox(height: 4),
                      _AlertItem(color: AppColors.textInactive),
                      const SizedBox(height: 3),
                      _AlertItem(color: AppColors.textInactive),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _ThresholdRow(),
                      const SizedBox(height: 3),
                      _ThresholdRow(),
                      const SizedBox(height: 3),
                      _ThresholdRow(),
                      const SizedBox(height: 3),
                      _ThresholdRow(),
                      const Spacer(),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
        border: Border(
          left: BorderSide(color: color, width: 2),
          top: BorderSide(color: AppColors.stroke),
          right: BorderSide(color: AppColors.stroke),
          bottom: BorderSide(color: AppColors.stroke),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 3),
          Container(
            width: 10,
            height: 2,
            color: AppColors.warning.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
