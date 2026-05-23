import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PlatformIcon extends StatelessWidget {
  const PlatformIcon({
    super.key,
    required this.platform,
    this.size = 16,
    this.color = AppColors.primary,
  });

  final String? platform;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardColor;
    return CustomPaint(
      size: Size(size, size),
      painter: _painterFor(platform, bg, color),
    );
  }

  CustomPainter _painterFor(String? platform, Color bg, Color fg) =>
      switch (platform) {
        'web' => _WebPainter(bg, fg),
        'chrome' => _ChromePainter(bg, fg),
        'firefox' => _FirefoxPainter(bg, fg),
        'safari' => _SafariPainter(bg, fg),
        'edge' => _EdgePainter(bg, fg),
        'opera' => _OperaPainter(bg, fg),
        'samsung' => _SamsungInternetPainter(bg, fg),
        'android' => _AndroidPainter(bg, fg),
        'ios' => _IosPainter(bg, fg),
        'macos' => _MacOsPainter(bg, fg),
        'windows' => _WindowsPainter(bg, fg),
        'linux' => _LinuxPainter(bg, fg),
        _ => _UnknownPainter(bg, fg),
      };
}

Paint _fill(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill;

Paint _cut(Color bg) => Paint()
  ..color = bg
  ..style = PaintingStyle.fill;

// ── Web — globo con meridianos cortados ───────────────────────────────────────

class _WebPainter extends CustomPainter {
  const _WebPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final r = s / 2;

    canvas.drawCircle(c, r, _fill(fg));

    final cut = _cut(bg)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.08;

    canvas.drawOval(
      Rect.fromCenter(center: c, width: s * 0.38, height: s),
      cut,
    );
    canvas.drawLine(Offset(0, s * 0.35), Offset(s, s * 0.35), cut);
    canvas.drawLine(Offset(0, s * 0.65), Offset(s, s * 0.65), cut);
  }

  @override
  bool shouldRepaint(_WebPainter old) => old.bg != bg || old.fg != fg;
}

// ── Chrome — círculo con centro cortado y tres segmentos ─────────────────────

class _ChromePainter extends CustomPainter {
  const _ChromePainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final f = _fill(fg);
    final cut = _cut(bg)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, s * 0.48, f);
    canvas.drawLine(
      Offset(s * 0.50, s * 0.50),
      Offset(s * 0.91, s * 0.50),
      cut,
    );
    canvas.drawLine(
      Offset(s * 0.50, s * 0.50),
      Offset(s * 0.28, s * 0.13),
      cut,
    );
    canvas.drawLine(
      Offset(s * 0.50, s * 0.50),
      Offset(s * 0.25, s * 0.86),
      cut,
    );
    canvas.drawCircle(c, s * 0.18, _cut(bg));
  }

  @override
  bool shouldRepaint(_ChromePainter old) => old.bg != bg || old.fg != fg;
}

// ── Firefox — llama envolviendo un centro cortado ────────────────────────────

class _FirefoxPainter extends CustomPainter {
  const _FirefoxPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill(fg);

    final flame = Path()
      ..moveTo(s * 0.84, s * 0.20)
      ..cubicTo(s * 0.70, s * 0.22, s * 0.66, s * 0.32, s * 0.71, s * 0.43)
      ..cubicTo(s * 0.55, s * 0.28, s * 0.34, s * 0.28, s * 0.22, s * 0.41)
      ..cubicTo(s * 0.08, s * 0.57, s * 0.15, s * 0.82, s * 0.36, s * 0.92)
      ..cubicTo(s * 0.58, s * 1.03, s * 0.86, s * 0.91, s * 0.93, s * 0.67)
      ..cubicTo(s * 0.98, s * 0.48, s * 0.91, s * 0.32, s * 0.84, s * 0.20)
      ..close();
    canvas.drawPath(flame, f);

    final tail = Path()
      ..moveTo(s * 0.36, s * 0.24)
      ..cubicTo(s * 0.24, s * 0.19, s * 0.18, s * 0.10, s * 0.18, s * 0.06)
      ..cubicTo(s * 0.33, s * 0.10, s * 0.44, s * 0.21, s * 0.48, s * 0.36)
      ..close();
    canvas.drawPath(tail, f);
    canvas.drawCircle(Offset(s * 0.52, s * 0.61), s * 0.21, _cut(bg));
  }

  @override
  bool shouldRepaint(_FirefoxPainter old) => old.bg != bg || old.fg != fg;
}

// ── Safari — brújula con aguja cortada ───────────────────────────────────────

class _SafariPainter extends CustomPainter {
  const _SafariPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final f = _fill(fg);

    canvas.drawCircle(c, s * 0.48, f);
    final cut = _cut(bg)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.08;
    canvas.drawCircle(c, s * 0.34, cut);

    final needle = Path()
      ..moveTo(s * 0.68, s * 0.17)
      ..lineTo(s * 0.55, s * 0.58)
      ..lineTo(s * 0.32, s * 0.83)
      ..lineTo(s * 0.45, s * 0.42)
      ..close();
    canvas.drawPath(needle, _cut(bg));
  }

  @override
  bool shouldRepaint(_SafariPainter old) => old.bg != bg || old.fg != fg;
}

// ── Edge — ola circular estilizada ───────────────────────────────────────────

class _EdgePainter extends CustomPainter {
  const _EdgePainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill(fg);

    final swirl = Path()
      ..moveTo(s * 0.91, s * 0.56)
      ..cubicTo(s * 0.86, s * 0.27, s * 0.59, s * 0.08, s * 0.32, s * 0.18)
      ..cubicTo(s * 0.13, s * 0.25, s * 0.04, s * 0.43, s * 0.10, s * 0.60)
      ..cubicTo(s * 0.20, s * 0.47, s * 0.38, s * 0.41, s * 0.55, s * 0.48)
      ..cubicTo(s * 0.39, s * 0.51, s * 0.27, s * 0.63, s * 0.26, s * 0.77)
      ..cubicTo(s * 0.38, s * 0.92, s * 0.63, s * 0.95, s * 0.80, s * 0.81)
      ..cubicTo(s * 0.89, s * 0.74, s * 0.93, s * 0.65, s * 0.91, s * 0.56)
      ..close();
    canvas.drawPath(swirl, f);
    canvas.drawCircle(Offset(s * 0.57, s * 0.64), s * 0.17, _cut(bg));
  }

  @override
  bool shouldRepaint(_EdgePainter old) => old.bg != bg || old.fg != fg;
}

// ── Opera — aro ovalado ──────────────────────────────────────────────────────

class _OperaPainter extends CustomPainter {
  const _OperaPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawOval(
      Rect.fromLTWH(s * 0.14, s * 0.03, s * 0.72, s * 0.94),
      _fill(fg),
    );
    canvas.drawOval(
      Rect.fromLTWH(s * 0.32, s * 0.20, s * 0.36, s * 0.60),
      _cut(bg),
    );
  }

  @override
  bool shouldRepaint(_OperaPainter old) => old.bg != bg || old.fg != fg;
}

// ── Samsung Internet — planeta con anillo ────────────────────────────────────

class _SamsungInternetPainter extends CustomPainter {
  const _SamsungInternetPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    canvas.drawCircle(c, s * 0.42, _fill(fg));
    final cut = _cut(bg)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.10;
    canvas.drawOval(
      Rect.fromCenter(center: c, width: s * 0.92, height: s * 0.44),
      cut,
    );
  }

  @override
  bool shouldRepaint(_SamsungInternetPainter old) =>
      old.bg != bg || old.fg != fg;
}

// ── Android — robot con antenas, ojos y brazos ───────────────────────────────

class _AndroidPainter extends CustomPainter {
  const _AndroidPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill(fg);
    final c = _cut(bg);

    final antennaPaint = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s * 0.33, s * 0.24),
      Offset(s * 0.22, s * 0.12),
      antennaPaint,
    );
    canvas.drawLine(
      Offset(s * 0.67, s * 0.24),
      Offset(s * 0.78, s * 0.12),
      antennaPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.17, s * 0.25, s * 0.67, s * 0.37),
        Radius.circular(s * 0.19),
      ),
      f,
    );

    canvas.drawCircle(Offset(s * 0.37, s * 0.44), s * 0.055, c);
    canvas.drawCircle(Offset(s * 0.63, s * 0.44), s * 0.055, c);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.17, s * 0.64, s * 0.67, s * 0.24),
        Radius.circular(s * 0.08),
      ),
      f,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.04, s * 0.64, s * 0.10, s * 0.24),
        Radius.circular(s * 0.05),
      ),
      f,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.86, s * 0.64, s * 0.10, s * 0.24),
        Radius.circular(s * 0.05),
      ),
      f,
    );
  }

  @override
  bool shouldRepaint(_AndroidPainter old) => old.bg != bg || old.fg != fg;
}

// ── iOS — manzana con mordisco ────────────────────────────────────────────────

class _IosPainter extends CustomPainter {
  const _IosPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    final body = Path()
      ..moveTo(s * 0.55, s * 0.24)
      ..cubicTo(s * 0.61, s * 0.19, s * 0.68, s * 0.18, s * 0.74, s * 0.22)
      ..cubicTo(s * 0.67, s * 0.26, s * 0.63, s * 0.33, s * 0.63, s * 0.42)
      ..cubicTo(s * 0.63, s * 0.52, s * 0.70, s * 0.60, s * 0.79, s * 0.63)
      ..cubicTo(s * 0.76, s * 0.72, s * 0.71, s * 0.82, s * 0.64, s * 0.91)
      ..cubicTo(s * 0.58, s * 0.98, s * 0.51, s * 0.94, s * 0.46, s * 0.91)
      ..cubicTo(s * 0.42, s * 0.88, s * 0.38, s * 0.88, s * 0.34, s * 0.91)
      ..cubicTo(s * 0.28, s * 0.95, s * 0.21, s * 0.98, s * 0.15, s * 0.90)
      ..cubicTo(s * 0.05, s * 0.76, s * 0.01, s * 0.55, s * 0.08, s * 0.40)
      ..cubicTo(s * 0.15, s * 0.26, s * 0.27, s * 0.20, s * 0.39, s * 0.25)
      ..cubicTo(s * 0.45, s * 0.28, s * 0.50, s * 0.28, s * 0.55, s * 0.24)
      ..close();

    final bite = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.81, s * 0.42), radius: s * 0.16),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, body, bite),
      _fill(fg),
    );

    final leaf = Path()
      ..moveTo(s * 0.50, s * 0.20)
      ..cubicTo(s * 0.52, s * 0.10, s * 0.62, s * 0.04, s * 0.73, s * 0.04)
      ..cubicTo(s * 0.72, s * 0.14, s * 0.62, s * 0.22, s * 0.50, s * 0.20)
      ..close();
    canvas.drawPath(leaf, _fill(fg));
  }

  @override
  bool shouldRepaint(_IosPainter old) => old.bg != bg || old.fg != fg;
}

// ── macOS — monitor con pantalla cortada ─────────────────────────────────────

class _MacOsPainter extends CustomPainter {
  const _MacOsPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill(fg);
    final c = _cut(bg);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s * 0.63),
        Radius.circular(s * 0.08),
      ),
      f,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.08, s * 0.08, s * 0.84, s * 0.46),
        Radius.circular(s * 0.04),
      ),
      c,
    );
    canvas.drawRect(Rect.fromLTWH(s * 0.42, s * 0.63, s * 0.17, s * 0.12), f);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.29, s * 0.75, s * 0.42, s * 0.08),
        Radius.circular(s * 0.04),
      ),
      f,
    );
  }

  @override
  bool shouldRepaint(_MacOsPainter old) => old.bg != bg || old.fg != fg;
}

// ── Windows — 4 polígonos en perspectiva ─────────────────────────────────────

class _WindowsPainter extends CustomPainter {
  const _WindowsPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill(fg);

    final left = s * 0.06;
    final midX = s * 0.47;
    final right = s * 0.94;
    final gap = s * 0.045;
    final topLeft = s * 0.18;
    final topRight = s * 0.10;
    final midLeft = s * 0.49;
    final midRight = s * 0.47;
    final bottomLeft = s * 0.84;
    final bottomRight = s * 0.92;

    canvas.drawPath(
      _poly([
        Offset(left, topLeft),
        Offset(midX - gap, topLeft - s * 0.045),
        Offset(midX - gap, midLeft - gap),
        Offset(left, midLeft),
      ]),
      f,
    );
    canvas.drawPath(
      _poly([
        Offset(midX + gap, topLeft - s * 0.055),
        Offset(right, topRight),
        Offset(right, midRight),
        Offset(midX + gap, midLeft - gap),
      ]),
      f,
    );
    canvas.drawPath(
      _poly([
        Offset(left, midLeft + gap),
        Offset(midX - gap, midLeft + gap),
        Offset(midX - gap, bottomLeft + s * 0.035),
        Offset(left, bottomLeft),
      ]),
      f,
    );
    canvas.drawPath(
      _poly([
        Offset(midX + gap, midLeft + gap),
        Offset(right, midRight + gap),
        Offset(right, bottomRight),
        Offset(midX + gap, bottomLeft + s * 0.045),
      ]),
      f,
    );
  }

  Path _poly(List<Offset> pts) {
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final pt in pts.skip(1)) {
      p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(_WindowsPainter old) => old.bg != bg || old.fg != fg;
}

// ── Linux — rectángulo teal con >_ cortado ────────────────────────────────────

class _LinuxPainter extends CustomPainter {
  const _LinuxPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(s * 0.10),
      ),
      _fill(fg),
    );

    final arrow = Path()
      ..moveTo(s * 0.17, s * 0.38)
      ..lineTo(s * 0.37, s * 0.50)
      ..lineTo(s * 0.17, s * 0.62)
      ..close();
    canvas.drawPath(arrow, _cut(bg));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.42, s * 0.55, s * 0.42, s * 0.09),
        Radius.circular(s * 0.02),
      ),
      _cut(bg),
    );
  }

  @override
  bool shouldRepaint(_LinuxPainter old) => old.bg != bg || old.fg != fg;
}

// ── Unknown — círculo con 4 puntos cortados ───────────────────────────────────

class _UnknownPainter extends CustomPainter {
  const _UnknownPainter(this.bg, this.fg);
  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, _fill(fg));

    final cut = _cut(bg);
    const offsets = [0.35, 0.65];
    for (final dx in offsets) {
      for (final dy in offsets) {
        canvas.drawCircle(Offset(s * dx, s * dy), s * 0.07, cut);
      }
    }
  }

  @override
  bool shouldRepaint(_UnknownPainter old) => old.bg != bg || old.fg != fg;
}
