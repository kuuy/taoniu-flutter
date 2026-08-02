import 'package:flutter/material.dart';

class MiniSparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;
  final bool showGradient;

  const MiniSparkline({
    super.key,
    required this.data,
    required this.color,
    this.width = 65,
    this.height = 26,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.length < 2) {
      return SizedBox(width: width, height: height);
    }

    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        data: data,
        lineColor: color,
        showGradient: showGradient,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showGradient;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.showGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (minVal == maxVal) {
      maxVal += 1.0;
      minVal -= 1.0;
    }

    final double stepX = size.width / (data.length - 1);
    final Path path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double normalizedY = (data[i] - minVal) / (maxVal - minVal);
      double y = size.height - (normalizedY * (size.height - 4)) - 2;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }

    if (showGradient) {
      final Path fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            lineColor.withValues(alpha: 0.3),
            lineColor.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
