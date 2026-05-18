import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MetricChartPlaceholder extends StatelessWidget {
  const MetricChartPlaceholder({
    super.key,
    required this.points,
    required this.lineColor,
    this.height = 180,
  });

  final List<double> points;
  final Color lineColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _LineChartPainter(points: points, lineColor: lineColor),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points, required this.lineColor});

  final List<double> points;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.24),
          lineColor.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    for (var index = 0; index < 4; index++) {
      final dy = size.height * (index / 3);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final path = Path();
    final fillPath = Path();
    for (var index = 0; index < points.length; index++) {
      final dx = size.width * index / (points.length - 1);
      final dy = size.height - (size.height * points[index]);
      if (index == 0) {
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
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
