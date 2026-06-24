import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gráfico de línea simple (sin dependencias) para la evolución del peso.
class WeightChart extends StatelessWidget {
  const WeightChart({
    super.key,
    required this.points,
    this.color = AppColors.growth,
  });

  final List<({String label, double kg})> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        );
    return Column(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => CustomPaint(
              painter: _WeightChartPainter(
                points: points,
                color: color,
                progress: progress,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final p in points)
              Expanded(
                child: Text(p.label, textAlign: TextAlign.center, style: labelStyle),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.points,
    required this.color,
    this.progress = 1,
  });

  final List<({String label, double kg})> points;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Revela el gráfico de izquierda a derecha según [progress].
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    const leftPad = 8.0;
    const rightPad = 8.0;
    const topPad = 16.0;
    const bottomPad = 8.0;

    final values = points.map((p) => p.kg).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    Offset toOffset(int i) {
      final x = leftPad + chartW * (i / (points.length - 1));
      final y = topPad + chartH * (1 - (values[i] - minV) / range);
      return Offset(x, y);
    }

    // Líneas guía horizontales.
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (var g = 0; g <= 2; g++) {
      final y = topPad + chartH * (g / 2);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
    }

    final offsets = [for (var i = 0; i < points.length; i++) toOffset(i)];

    // Área bajo la curva.
    final areaPath = Path()..moveTo(offsets.first.dx, size.height - bottomPad);
    for (final o in offsets) {
      areaPath.lineTo(o.dx, o.dy);
    }
    areaPath.lineTo(offsets.last.dx, size.height - bottomPad);
    areaPath.close();
    canvas.drawPath(
      areaPath,
      Paint()..color = color.withValues(alpha: 0.12),
    );

    // Línea.
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Puntos.
    final dotFill = Paint()..color = color;
    final dotBorder = Paint()..color = Colors.white;
    for (final o in offsets) {
      canvas.drawCircle(o, 5, dotBorder);
      canvas.drawCircle(o, 3.5, dotFill);
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.progress != progress;
}
