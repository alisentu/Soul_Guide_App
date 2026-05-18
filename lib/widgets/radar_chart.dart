import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/analysis_data.dart';
import 'dart:math' as math;

/// SVG tabanlı Radar Chart
/// Source: analiz_ekran_soft_pastel/code.html - SVG radar polygon
class RadarChart extends StatefulWidget {
  final List<RadarDimension> dimensions;
  final double size;

  const RadarChart({
    super.key,
    required this.dimensions,
    this.size = 280,
  });

  @override
  State<RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Concentric circles + axes
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarGridPainter(),
              ),
              // Data polygon
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarDataPainter(
                  dimensions: widget.dimensions,
                  animationValue: _animation.value,
                ),
              ),
              // Labels
              ...List.generate(widget.dimensions.length, (i) {
                final angle = (2 * math.pi * i / widget.dimensions.length) -
                    math.pi / 2;
                final radius = widget.size / 2 + 24;
                final x = widget.size / 2 + radius * math.cos(angle);
                final y = widget.size / 2 + radius * math.sin(angle);

                return Positioned(
                  left: x - 36,
                  top: y - 10,
                  child: SizedBox(
                    width: 72,
                    child: Text(
                      widget.dimensions[i].label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.75;
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Concentric circles (4 levels)
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * i / 4, gridPaint);
    }

    // Axis lines (5 dimensions)
    const count = 5;
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi * i / count) - math.pi / 2;
      final end = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);
    }
  }

  @override
  bool shouldRepaint(_RadarGridPainter old) => false;
}

class _RadarDataPainter extends CustomPainter {
  final List<RadarDimension> dimensions;
  final double animationValue;

  _RadarDataPainter({
    required this.dimensions,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dimensions.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.75;
    final count = dimensions.length;

    final points = List.generate(count, (i) {
      final angle = (2 * math.pi * i / count) - math.pi / 2;
      final value = dimensions[i].value * animationValue;
      return Offset(
        center.dx + maxRadius * value * math.cos(angle),
        center.dy + maxRadius * value * math.sin(angle),
      );
    });

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    // Fill with gradient
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x99B4D4FF),
          Color(0x33D2BFE7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Data points
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RadarDataPainter old) =>
      old.animationValue != animationValue;
}
