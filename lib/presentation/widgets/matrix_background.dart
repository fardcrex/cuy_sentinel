import 'dart:math' as math;

import 'package:flutter/material.dart';

class MatrixBackgroundPainter extends CustomPainter {
  const MatrixBackgroundPainter({
    required this.progress,
    this.density = 0.35,
    this.toneColor = const Color(0xFF5CE673),
    this.accentToneColor = const Color(0xFF22F5C7),
  });

  final double progress;
  final double density;
  final Color toneColor;
  final Color accentToneColor;

  double _noise(int seed) {
    final value = math.sin(seed * 12.9898) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final densityFactor = density.clamp(0.15, 1.0);
    final spacing = 132 - (densityFactor * 62);
    final columnCount = math.max(8, (size.width / spacing).floor());
    const baseStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );

    for (var index = 0; index < columnCount; index++) {
      final seed = index + 1;
      final baseX = (index + 0.5) * size.width / columnCount;
      final drift =
          math.sin((progress * math.pi * 2) + index * 0.7) * 10;
      final x = baseX + drift;
      final streamLength = 4 + (index % 3);
      final travel = (progress + (index * 0.073)) % 1.0;
      final headY = travel * (size.height + 220) - 220;

      for (var segment = 0; segment < streamLength; segment++) {
        final y = headY - (segment * 26);
        if (y < -20 || y > size.height + 20) continue;

        final baseOpacity =
            (0.2 + (_noise(seed * 43) * 0.08) - (segment * 0.028))
                .clamp(0.035, 0.24);
        final binaryChar =
            ((index + segment + (progress * 10).floor()) % 2 == 0)
                ? '0'
                : '1';
        final blendFactor =
            ((segment / streamLength) * 0.45) +
            (_noise((seed * 59) + segment) * 0.35);
        final glyphColor = Color.lerp(
          toneColor,
          accentToneColor,
          blendFactor.clamp(0.0, 1.0),
        )!;
        final opacity = (baseOpacity * 1.15).clamp(0.04, 0.28);
        final textPainter = TextPainter(
          text: TextSpan(
            text: binaryChar,
            style: baseStyle.copyWith(
              color: glyphColor.withValues(alpha: opacity),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - (textPainter.width / 2),
            y - (textPainter.height / 2),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatrixBackgroundPainter old) =>
      old.progress != progress ||
      old.density != density ||
      old.toneColor != toneColor ||
      old.accentToneColor != accentToneColor;
}
