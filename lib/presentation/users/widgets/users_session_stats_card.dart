import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../user_model.dart';

class UsersSessionStatsCard extends StatelessWidget {
  const UsersSessionStatsCard({super.key, required this.session});

  final UsersSessionModel session;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de sesiones',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          UsersStatRow(
            icon: Icons.people_rounded,
            label: 'Total de usuarios',
            value: session.total,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          UsersStatRow(
            icon: Icons.circle,
            label: 'En línea ahora',
            value: session.online,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          UsersStatRow(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Administradores',
            value: session.admins,
            color: AppColors.primaryBright,
          ),
          const SizedBox(height: 14),
          UsersStatRow(
            icon: Icons.visibility_outlined,
            label: 'Visualizadores',
            value: session.viewers,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Autenticación con contraseña. JWT en Fase 2.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
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

class UsersStatRow extends StatelessWidget {
  const UsersStatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
