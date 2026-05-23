import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/platform_icon_painter.dart';
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
                  deviceLabel: m.deviceLabel,
                  devicePlatform: m.devicePlatform,
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
    this.deviceLabel,
    this.devicePlatform,
  });

  final String user;
  final String action;
  final String timestamp;
  final Color color;
  final String? deviceLabel;
  final String? devicePlatform;

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
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              RichText(
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
              if (deviceLabel != null)
                _DeviceChip(label: deviceLabel!, platform: devicePlatform),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timestamp,
          style: const TextStyle(color: AppColors.textInactive, fontSize: 11),
        ),
      ],
    );
  }
}

class _DeviceChip extends StatelessWidget {
  const _DeviceChip({required this.label, required this.platform});

  final String label;
  final String? platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        border: Border.all(color: AppColors.textInactive.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformIcon(platform: platform, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
