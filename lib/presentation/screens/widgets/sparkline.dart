import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    required this.color,
    this.width = 80,
    this.height = 32,
  });

  final List<double> points;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SparklinePainter(points: points, color: color)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final dx = size.width * i / (points.length - 1);
      final dy = size.height - (size.height * points[i]);
      if (i == 0) {
        path.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, size.height)
          ..lineTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.points != points || old.color != color;
}
