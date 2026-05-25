import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Renderizador de línea animado. Acepta `List<double?>`:
/// - double: valor normalizado [0, 1] para esa posición
/// - null: gap visible (pincel levantado)
///
/// Backward-compatible: `List<double>` es subtipo de `List<double?>` en Dart.
class MetricChartPlaceholder extends StatefulWidget {
  const MetricChartPlaceholder({
    super.key,
    required this.points,
    required this.lineColor,
    this.height = 180,
    this.duration = const Duration(milliseconds: 700),
  });

  final List<double?> points;
  final Color lineColor;
  final double height;
  final Duration duration;

  @override
  State<MetricChartPlaceholder> createState() => _MetricChartPlaceholderState();
}

class _MetricChartPlaceholderState extends State<MetricChartPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<double?> _fromPoints;
  late List<double?> _toPoints;
  var _useSlidingWindowTransition = false;

  @override
  void initState() {
    super.initState();
    _fromPoints = List<double?>.from(widget.points);
    _toPoints = List<double?>.from(widget.points);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant MetricChartPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (!_samePoints(oldWidget.points, widget.points)) {
      _fromPoints = _interpolatePoints(_controller.value);
      _toPoints = List<double?>.from(widget.points);
      _useSlidingWindowTransition = _isSlidingWindowUpdate(
        oldWidget.points,
        widget.points,
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
        builder: (context, child) {
          final progress = Curves.easeOutCubic.transform(_controller.value);
          return CustomPaint(
            painter: _LineChartPainter(
              fromPoints: _fromPoints,
              toPoints: _toPoints,
              lineColor: widget.lineColor,
              progress: progress,
              useSlidingWindowTransition: _useSlidingWindowTransition,
            ),
          );
        },
      ),
    );
  }

  bool _samePoints(List<double?> a, List<double?> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<double?> _interpolatePoints(double progress) {
    final targetLen = _fromPoints.length > _toPoints.length
        ? _fromPoints.length
        : _toPoints.length;
    if (targetLen == 0) return const [];
    final from = _normalizeLength(_fromPoints, targetLen);
    final to = _normalizeLength(_toPoints, targetLen);
    return List<double?>.generate(targetLen, (i) {
      final f = from[i];
      final t = to[i];
      if (f == null || t == null) return null;
      return f + ((t - f) * progress);
    });
  }

  List<double?> _normalizeLength(List<double?> source, int targetLen) {
    if (source.isEmpty) return List<double?>.filled(targetLen, null);
    if (source.length == targetLen) return List<double?>.from(source);
    if (source.length > targetLen) return source.take(targetLen).toList();
    return List<double?>.filled(targetLen - source.length, source.first) +
        source;
  }

  bool _isSlidingWindowUpdate(List<double?> previous, List<double?> next) {
    if (previous.length != next.length || previous.length < 2) return false;
    for (var i = 0; i < previous.length - 1; i++) {
      final prev = previous[i + 1];
      final nxt = next[i];
      if (prev == null || nxt == null) return false;
      if ((prev - nxt).abs() > 0.0001) return false;
    }
    return true;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.fromPoints,
    required this.toPoints,
    required this.lineColor,
    required this.progress,
    required this.useSlidingWindowTransition,
  });

  final List<double?> fromPoints;
  final List<double?> toPoints;
  final Color lineColor;
  final double progress;
  final bool useSlidingWindowTransition;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final targetLen = fromPoints.length > toPoints.length
        ? fromPoints.length
        : toPoints.length;
    if (targetLen == 0) {
      canvas.restore();
      return;
    }

    final normFrom = _normalizeLength(fromPoints, targetLen);
    final normTo = _normalizeLength(toPoints, targetLen);

    final gridPaint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final dy = size.height * (i / 3);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final stepX = targetLen <= 1 ? 0.0 : size.width / (targetLen - 1);
    final oldShift = -stepX * progress;
    final newShift = stepX * (1 - progress);

    final oldLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 1 - progress)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final newLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint fillPaint(double alpha) => Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.24 * alpha),
          lineColor.withValues(alpha: 0.02 * alpha),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    if (useSlidingWindowTransition && progress < 1) {
      _drawSeries(
        canvas,
        size,
        normFrom,
        oldShift,
        fillPaint(1 - progress),
        oldLinePaint,
      );
    }

    if (useSlidingWindowTransition) {
      _drawSeries(
        canvas,
        size,
        normTo,
        newShift,
        fillPaint(progress),
        newLinePaint,
      );
    } else {
      final interpolated = List<double?>.generate(targetLen, (i) {
        final f = normFrom[i];
        final t = normTo[i];
        if (f == null || t == null) return null;
        return f + ((t - f) * progress);
      });
      _drawSeries(canvas, size, interpolated, 0, fillPaint(1.0), newLinePaint);
    }

    canvas.restore();
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    List<double?> points,
    double hShift,
    Paint fillPaint,
    Paint linePaint,
  ) {
    if (points.isEmpty) return;
    final n = points.length;
    var linePath = Path();
    var fillPath = Path();
    var segmentStarted = false;
    var lastDx = 0.0;

    void closeSegment() {
      if (!segmentStarted) return;
      fillPath
        ..lineTo(lastDx, size.height)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
      linePath = Path();
      fillPath = Path();
      segmentStarted = false;
    }

    // When the new series enters from the right (hShift > 0, sliding-window
    // animation), extend it horizontally to x=0 at the height of its first
    // point so the left edge is always filled.
    if (hShift > 0 && points.isNotEmpty && points[0] != null) {
      final dy = size.height - (size.height * points[0]!);
      linePath.moveTo(0, dy);
      fillPath
        ..moveTo(0, size.height)
        ..lineTo(0, dy);
      segmentStarted = true;
      lastDx = 0.0;
    }

    for (var i = 0; i < n; i++) {
      final value = points[i];
      final dx = (n == 1 ? 0.0 : (size.width * i / (n - 1))) + hShift;

      if (value == null) {
        closeSegment();
        continue;
      }

      final dy = size.height - (size.height * value);
      if (!segmentStarted) {
        linePath.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, size.height)
          ..lineTo(dx, dy);
        segmentStarted = true;
      } else {
        linePath.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
      lastDx = dx;
    }
    closeSegment();
  }

  List<double?> _normalizeLength(List<double?> source, int targetLen) {
    if (source.isEmpty) return List<double?>.filled(targetLen, null);
    if (source.length == targetLen) return List<double?>.from(source);
    if (source.length > targetLen) return source.take(targetLen).toList();
    return List<double?>.filled(targetLen - source.length, source.first) +
        source;
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.fromPoints != fromPoints ||
      old.toPoints != toPoints ||
      old.lineColor != lineColor ||
      old.progress != progress ||
      old.useSlidingWindowTransition != useSlidingWindowTransition;
}
