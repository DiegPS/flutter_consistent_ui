import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Clean, lightweight vector sparkline for KPI cards and dashboards.
///
/// Draws a smoothed cubic Bezier trend line with a subtle gradient area.
class UiSparkline extends StatelessWidget {
  const UiSparkline({
    required this.data,
    this.color,
    this.lineWidth = 2.0,
    this.fill = true,
    this.height = 24,
    this.width = 64,
    super.key,
  });

  final List<double> data;
  final Color? color;
  final double lineWidth;
  final bool fill;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);

    final lineColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          lineColor: lineColor,
          lineWidth: lineWidth,
          fill: fill,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.lineWidth,
    required this.fill,
  });

  final List<double> data;
  final Color lineColor;
  final double lineWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final points = <Offset>[];
    final dx = data.length > 1 ? size.width / (data.length - 1) : size.width;

    for (var i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minVal) / range;
      // Invert Y because canvas (0,0) is top-left, and add 2px inset so line doesn't clip
      final y = size.height - 2 - (normalizedY * (size.height - 4));
      final x = data.length > 1 ? i * dx : size.width / 2;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    if (points.length == 1) {
      path.lineTo(size.width, points.first.dy);
    } else {
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }
    }

    if (fill && points.isNotEmpty) {
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.22),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.lineWidth != lineWidth ||
      oldDelegate.fill != fill;
}
