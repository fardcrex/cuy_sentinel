import 'dart:math' as math;

import 'package:flutter/material.dart';

// Binary-weighted + cyber symbols + hex — no letters that read as words.
const _glyphs = [
  '0', '1', '0', '1', '0', '1', // binary weighted
  '/', r'\', '|', '+', '*', '#',
  '!', '?', '~', ':', '=', '^',
  'A', 'F', 'E', '3', '7', 'B',
];

class MatrixBackgroundPainter extends CustomPainter {
  const MatrixBackgroundPainter({
    required this.progress,
    this.density = 0.55,
    this.toneColor = const Color(0xFF5CE673),
    this.accentToneColor = const Color(0xFF22F5C7),
    this.scrollOffset = 0.0,
  });

  final double progress;
  final double density;
  final Color toneColor;
  final Color accentToneColor;
  // Parallax: matrix moves at 50% of scroll speed
  final double scrollOffset;

  double _noise(int seed) {
    final value = math.sin(seed * 12.9898) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final parallaxShift = scrollOffset * 0.5;
    canvas.save();
    canvas.translate(0, -parallaxShift);
    final effectiveHeight = size.height + parallaxShift;
    final densityFactor = density.clamp(0.15, 1.0);
    final spacing = 150 - (densityFactor * 55);
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
          math.sin((progress * math.pi * 2) + index * 0.7) * 8;
      final x = baseX + drift;
      // Each column falls at its own speed (0.75x–1.9x) with its own phase offset.
      final speed = 0.75 + _noise(seed * 17) * 1.15;
      final phase = _noise(seed * 31);
      final travel = (progress * speed + phase) % 1.0;
      final streamLength = 10 + (_noise(seed * 53) * 9).floor(); // 10–19 chars
      final headY = travel * (effectiveHeight + 240) - 240;

      for (var segment = 0; segment < streamLength; segment++) {
        final y = headY - (segment * 24);
        if (y < -20 || y > effectiveHeight + 20) continue;

        // Exponential fade toward tail for a natural trail.
        final tailFade = math.pow(
          1.0 - segment / streamLength,
          1.6,
        ).toDouble();
        final baseOpacity =
            (tailFade * 0.60 + _noise(seed * 43) * 0.08).clamp(0.04, 0.65);
        // Each segment flips at its own rate (4x–24x per cycle) — no sync.
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
        final glyphColor = Color.lerp(
          toneColor,
          accentToneColor,
          blendFactor.clamp(0.0, 1.0),
        )!;
        final opacity = baseOpacity.clamp(0.04, 0.65);
        final textPainter = TextPainter(
          text: TextSpan(
            text: glyph,
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
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MatrixBackgroundPainter old) =>
      old.progress != progress ||
      old.density != density ||
      old.toneColor != toneColor ||
      old.accentToneColor != accentToneColor ||
      old.scrollOffset != scrollOffset;
}
