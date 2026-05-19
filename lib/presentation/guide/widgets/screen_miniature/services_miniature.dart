import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'mini_shared.dart';

class ServicesMiniature extends StatefulWidget {
  const ServicesMiniature({super.key});

  @override
  State<ServicesMiniature> createState() => _ServicesMiniatureState();
}

class _ServicesMiniatureState extends State<ServicesMiniature> {
  bool _showDb = false;

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
              MiniTabPill(
                label: 'Servicios',
                active: !_showDb,
                onTap: () => setState(() => _showDb = false),
              ),
              const SizedBox(width: 4),
              MiniTabPill(
                label: 'BD',
                active: _showDb,
                onTap: () => setState(() => _showDb = true),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showDb
                  ? const _DbView(key: ValueKey('db'))
                  : const _ServicesView(key: ValueKey('svc')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesView extends StatelessWidget {
  const _ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _ServiceCard(color: AppColors.primary)),
              const SizedBox(width: 4),
              Expanded(child: _ServiceCard(color: AppColors.secondary)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.stroke),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 3,
                height: double.infinity,
                color: AppColors.textInactive.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 5),
              Container(
                width: 40,
                height: 3,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 3,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(width: double.infinity, height: 1, color: AppColors.stroke),
          const SizedBox(height: 5),
          Container(
            width: 30,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 3),
          Container(
            width: 22,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 3),
          Container(
            width: 26,
            height: 2,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _DbView extends StatelessWidget {
  const _DbView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                for (var i = 0; i < 4; i++) ...[
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(child: MiniBox(accentColor: AppColors.secondary)),
              const SizedBox(height: 3),
              const Expanded(child: MiniBox()),
              const SizedBox(height: 3),
              const Expanded(child: MiniBox()),
            ],
          ),
        ),
      ],
    );
  }
}
