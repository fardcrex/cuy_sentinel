import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MiniBox extends StatelessWidget {
  const MiniBox({super.key, this.accentColor, this.height});

  final Color? accentColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: accentColor?.withValues(alpha: 0.35) ?? AppColors.stroke,
        ),
      ),
    );
  }
}

class MiniChartBox extends StatelessWidget {
  const MiniChartBox({super.key, required this.color, this.points});

  final Color color;
  final List<double>? points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stroke),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: MiniLinePainter(color: color, points: points),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class MiniLinePainter extends CustomPainter {
  const MiniLinePainter({required this.color, this.points});

  final Color color;
  final List<double>? points;

  static const _defaultPoints = [
    0.0, 0.55,
    0.15, 0.75,
    0.30, 0.40,
    0.45, 0.65,
    0.60, 0.30,
    0.75, 0.55,
    0.90, 0.25,
    1.0, 0.45,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final pts = points ?? _defaultPoints;
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < pts.length; i += 2) {
      final x = pts[i] * size.width;
      final y = size.height - pts[i + 1] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = color.withValues(alpha: 0.07),
    );
  }

  @override
  bool shouldRepaint(covariant MiniLinePainter old) =>
      old.color != color || old.points != points;
}

class MiniTabPill extends StatelessWidget {
  const MiniTabPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
