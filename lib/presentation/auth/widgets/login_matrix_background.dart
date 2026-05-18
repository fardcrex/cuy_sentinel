import 'dart:math' as math;

import 'package:flutter/material.dart';

const _glyphs = [
  '0', '1', '0', '1', '0', '1',
  '/', r'\', '|', '+', '*', '#',
  '!', '?', '~', ':', '=', '^',
  'A', 'F', 'E', '3', '7', 'B',
];

class LoginMatrixBackgroundPainter extends CustomPainter {
  LoginMatrixBackgroundPainter({
    required this.progress,
    required this.density,
    required this.toneColor,
    required this.accentToneColor,
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
    final spacing = 145 - (densityFactor * 50);
    final columnCount = math.max(8, (size.width / spacing).floor());
    final isAlert = toneColor.r > toneColor.g;

    for (var index = 0; index < columnCount; index++) {
      final seed = index + 1;

      // depth: 0.0 = lejano, 1.0 = cercano — fijo por columna via noise.
      final depth = _noise(seed * 41);

      // Tamaño de fuente: 7px (lejos) → 14px (cerca).
      final fontSize = 7.0 + depth * 7.0;

      // Multiplicador de opacidad por profundidad: 0.28x (lejos) → 1.0x (cerca).
      final depthOpacity = 0.28 + depth * 0.72;

      // Separación entre segmentos proporcional al tamaño.
      final segSpacing = 14.0 + depth * 12.0; // 14px → 26px

      // Columnas cercanas caen más rápido (paralaje).
      final speed = (0.45 + depth * 0.9) + _noise(seed * 17) * 0.5;
      final phase = _noise(seed * 31);
      final travel = (progress * speed + phase) % 1.0;

      final baseX = (index + 0.5) * size.width / columnCount;
      final drift = math.sin((progress * math.pi * 2) + index * 0.7) * 8;
      final x = baseX + drift;
      final streamLength = 10 + (_noise(seed * 53) * 9).floor();
      final headY = travel * (size.height + 240) - 240;

      for (var segment = 0; segment < streamLength; segment++) {
        final y = headY - (segment * segSpacing);
        if (y < -20 || y > size.height + 20) continue;

        final tailFade = math.pow(
          1.0 - segment / streamLength,
          1.6,
        ).toDouble();
        final segFlipSpeed = 4.0 + _noise((seed * 83) + segment * 19) * 20.0;
        final segTick = (progress * segFlipSpeed).floor();
        final charIdx =
            (_noise((seed * 97) + segment * 11 + segTick * 7) * _glyphs.length)
                .floor()
                .clamp(0, _glyphs.length - 1);
        final glyph = _glyphs[charIdx];
        final blendFactor =
            ((segment / streamLength) * 0.5) +
            (_noise((seed * 59) + segment) * 0.3);

        final Color glyphColor;
        final double opacity;

        if (isAlert) {
          final headFraction = (1.0 - segment / streamLength).clamp(0.0, 1.0);
          glyphColor = Color.lerp(
            toneColor,
            const Color(0xFFFFE0E0),
            math.pow(headFraction, 2.2).toDouble(),
          )!;
          opacity = (math.pow(headFraction, 1.4) * 0.92 + 0.06)
              .toDouble()
              .clamp(0.06, 0.92) *
              depthOpacity;
        } else {
          glyphColor = Color.lerp(
            toneColor,
            accentToneColor,
            blendFactor.clamp(0.0, 1.0),
          )!;
          opacity = (tailFade * 0.62 + _noise(seed * 43) * 0.08).clamp(0.04, 0.65) *
              depthOpacity;
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: glyph,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: glyphColor.withValues(alpha: opacity.clamp(0.03, 0.92)),
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
  bool shouldRepaint(covariant LoginMatrixBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.density != density ||
      oldDelegate.toneColor != toneColor ||
      oldDelegate.accentToneColor != accentToneColor;
}