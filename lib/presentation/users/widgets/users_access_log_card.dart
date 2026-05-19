import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../user_model.dart';

class UsersAccessLogCard extends StatelessWidget {
  const UsersAccessLogCard({super.key, required this.logs});

  final List<AccessLogModel> logs;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos recientes',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Sin registros',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...List.generate(logs.length, (i) {
              final m = logs[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < logs.length - 1 ? 10 : 0),
                child: UsersLogEntry(
                  user: m.user,
                  action: m.action,
                  timestamp: m.timestamp,
                  color: m.color,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class UsersLogEntry extends StatelessWidget {
  const UsersLogEntry({
    super.key,
    required this.user,
    required this.action,
    required this.timestamp,
    required this.color,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: user,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' · $action',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          timestamp,
          style: const TextStyle(color: AppColors.textInactive, fontSize: 11),
        ),
      ],
    );
  }
}
