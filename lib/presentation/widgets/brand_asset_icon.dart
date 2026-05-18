import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrandAssetIcon extends StatelessWidget {
  const BrandAssetIcon({
    super.key,
    required this.assetPath,
    this.size = 48,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor,
    this.borderColor,
  });

  final String assetPath;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? AppColors.stroke),
      ),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
