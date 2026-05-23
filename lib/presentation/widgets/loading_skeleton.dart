import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LoadingSkeletonPulse extends StatefulWidget {
  const LoadingSkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<LoadingSkeletonPulse> createState() => _LoadingSkeletonPulseState();
}

class _LoadingSkeletonPulseState extends State<LoadingSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.45)),
      ),
    );
  }
}
