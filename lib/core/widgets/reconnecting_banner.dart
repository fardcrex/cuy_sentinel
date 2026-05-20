import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ReconnectingBanner extends StatefulWidget {
  const ReconnectingBanner({super.key, this.secondsLeft});

  /// Segundos restantes para el próximo reintento.
  /// null o 0 → muestra "Reconectando..." sin countdown.
  final int? secondsLeft;

  @override
  State<ReconnectingBanner> createState() => _ReconnectingBannerState();
}

class _ReconnectingBannerState extends State<ReconnectingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String get _label {
    final s = widget.secondsLeft;
    if (s != null && s > 0) return 'RECONECTANDO EN ${s}S';
    return 'RECONECTANDO';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.darkPanel,
        border: Border(
          left: BorderSide(color: AppColors.warningAmber, width: 3),
          bottom: BorderSide(color: AppColors.borderTech),
        ),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.warningAmber,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.wifi_off_rounded,
            size: 13,
            color: AppColors.warningAmber,
          ),
          const SizedBox(width: 7),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _label,
              key: ValueKey(_label),
              style: const TextStyle(
                color: AppColors.warningAmber,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          FadeTransition(
            opacity: _opacity,
            child: const Text(
              '● ● ●',
              style: TextStyle(
                color: AppColors.warningAmber,
                fontSize: 9,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
