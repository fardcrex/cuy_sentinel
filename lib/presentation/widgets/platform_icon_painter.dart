import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PlatformIcon extends StatelessWidget {
  const PlatformIcon({super.key, required this.platform, this.size = 16});

  final String? platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardColor;
    return CustomPaint(
      size: Size(size, size),
      painter: _painterFor(platform, bg),
    );
  }

  CustomPainter _painterFor(String? platform, Color bg) => switch (platform) {
    'web'     => _WebPainter(bg),
    'android' => _AndroidPainter(bg),
    'ios'     => _IosPainter(bg),
    'macos'   => _MacOsPainter(bg),
    'windows' => _WindowsPainter(bg),
    'linux'   => _LinuxPainter(bg),
    _         => _UnknownPainter(bg),
  };
}

Paint _fill() => Paint()
  ..color = AppColors.primary
  ..style = PaintingStyle.fill;

Paint _cut(Color bg) => Paint()
  ..color = bg
  ..style = PaintingStyle.fill;

// ── Web — globo con meridianos cortados ───────────────────────────────────────

class _WebPainter extends CustomPainter {
  const _WebPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final r = s / 2;

    canvas.drawCircle(c, r, _fill());

    final cut = _cut(bg)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.08;

    canvas.drawOval(Rect.fromCenter(center: c, width: s * 0.38, height: s), cut);
    canvas.drawLine(Offset(0, s * 0.35), Offset(s, s * 0.35), cut);
    canvas.drawLine(Offset(0, s * 0.65), Offset(s, s * 0.65), cut);
  }

  @override
  bool shouldRepaint(_WebPainter old) => old.bg != bg;
}

// ── Android — robot con antenas, ojos y brazos ───────────────────────────────

class _AndroidPainter extends CustomPainter {
  const _AndroidPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill();
    final c = _cut(bg);

    final antennaPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.33, s * 0.24), Offset(s * 0.22, s * 0.12), antennaPaint);
    canvas.drawLine(Offset(s * 0.67, s * 0.24), Offset(s * 0.78, s * 0.12), antennaPaint);

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

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.04, s * 0.64, s * 0.10, s * 0.24), Radius.circular(s * 0.05)), f);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.86, s * 0.64, s * 0.10, s * 0.24), Radius.circular(s * 0.05)), f);
  }

  @override
  bool shouldRepaint(_AndroidPainter old) => old.bg != bg;
}

// ── iOS — manzana con mordisco ────────────────────────────────────────────────

class _IosPainter extends CustomPainter {
  const _IosPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    final body = Path()
      ..moveTo(s * 0.33, s * 0.27)
      ..cubicTo(s * 0.21, s * 0.27, s * 0.10, s * 0.40, s * 0.10, s * 0.56)
      ..cubicTo(s * 0.10, s * 0.75, s * 0.23, s * 0.94, s * 0.37, s * 0.94)
      ..cubicTo(s * 0.42, s * 0.94, s * 0.47, s * 0.91, s * 0.50, s * 0.91)
      ..cubicTo(s * 0.53, s * 0.91, s * 0.58, s * 0.94, s * 0.63, s * 0.94)
      ..cubicTo(s * 0.77, s * 0.94, s * 0.90, s * 0.75, s * 0.90, s * 0.56)
      ..cubicTo(s * 0.90, s * 0.40, s * 0.79, s * 0.27, s * 0.67, s * 0.27)
      ..cubicTo(s * 0.61, s * 0.27, s * 0.56, s * 0.30, s * 0.50, s * 0.30)
      ..cubicTo(s * 0.44, s * 0.30, s * 0.39, s * 0.27, s * 0.33, s * 0.27)
      ..close();

    final bite = Path()
      ..addOval(Rect.fromCircle(center: Offset(s * 0.73, s * 0.33), radius: s * 0.18));

    canvas.drawPath(Path.combine(PathOperation.difference, body, bite), _fill());

    final leaf = Path()
      ..moveTo(s * 0.52, s * 0.23)
      ..cubicTo(s * 0.54, s * 0.14, s * 0.67, s * 0.10, s * 0.69, s * 0.08)
      ..cubicTo(s * 0.67, s * 0.14, s * 0.58, s * 0.19, s * 0.52, s * 0.23)
      ..close();
    canvas.drawPath(leaf, _fill());
  }

  @override
  bool shouldRepaint(_IosPainter old) => old.bg != bg;
}

// ── macOS — monitor con pantalla cortada ─────────────────────────────────────

class _MacOsPainter extends CustomPainter {
  const _MacOsPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill();
    final c = _cut(bg);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s * 0.63), Radius.circular(s * 0.08)),
      f,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.08, s * 0.08, s * 0.84, s * 0.46), Radius.circular(s * 0.04)),
      c,
    );
    canvas.drawRect(Rect.fromLTWH(s * 0.42, s * 0.63, s * 0.17, s * 0.12), f);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.29, s * 0.75, s * 0.42, s * 0.08), Radius.circular(s * 0.04)),
      f,
    );
  }

  @override
  bool shouldRepaint(_MacOsPainter old) => old.bg != bg;
}

// ── Windows — 4 polígonos en perspectiva ─────────────────────────────────────

class _WindowsPainter extends CustomPainter {
  const _WindowsPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final f = _fill();

    canvas.drawPath(_poly([
      Offset(s * 0.08, s * 0.25), Offset(s * 0.44, s * 0.19),
      Offset(s * 0.44, s * 0.48), Offset(s * 0.08, s * 0.52),
    ]), f);
    canvas.drawPath(_poly([
      Offset(s * 0.47, s * 0.18), Offset(s * 0.92, s * 0.10),
      Offset(s * 0.92, s * 0.48), Offset(s * 0.47, s * 0.48),
    ]), f);
    canvas.drawPath(_poly([
      Offset(s * 0.08, s * 0.54), Offset(s * 0.44, s * 0.52),
      Offset(s * 0.44, s * 0.81), Offset(s * 0.08, s * 0.88),
    ]), f);
    canvas.drawPath(_poly([
      Offset(s * 0.47, s * 0.52), Offset(s * 0.92, s * 0.52),
      Offset(s * 0.92, s * 0.90), Offset(s * 0.47, s * 0.90),
    ]), f);
  }

  Path _poly(List<Offset> pts) {
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final pt in pts.skip(1)) { p.lineTo(pt.dx, pt.dy); }
    return p..close();
  }

  @override
  bool shouldRepaint(_WindowsPainter old) => old.bg != bg;
}

// ── Linux — rectángulo teal con >_ cortado ────────────────────────────────────

class _LinuxPainter extends CustomPainter {
  const _LinuxPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.10)),
      _fill(),
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
  bool shouldRepaint(_LinuxPainter old) => old.bg != bg;
}

// ── Unknown — círculo con 4 puntos cortados ───────────────────────────────────

class _UnknownPainter extends CustomPainter {
  const _UnknownPainter(this.bg);
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, _fill());

    final cut = _cut(bg);
    const offsets = [0.35, 0.65];
    for (final dx in offsets) {
      for (final dy in offsets) {
        canvas.drawCircle(Offset(s * dx, s * dy), s * 0.07, cut);
      }
    }
  }

  @override
  bool shouldRepaint(_UnknownPainter old) => old.bg != bg;
}
