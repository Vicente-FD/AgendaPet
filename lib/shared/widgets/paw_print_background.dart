import 'package:flutter/material.dart';

/// Fondo decorativo con huellas de mascota dispersas (marca de agua suave).
///
/// Se usa detrás del onboarding y de tarjetas destacadas. Las posiciones son
/// fijas (sin azar) para mantener un look consistente.
class PawPrintBackground extends StatelessWidget {
  const PawPrintBackground({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.opacity = 0.06,
  });

  final Widget child;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PawPrintPainter(
                color: color.withValues(alpha: opacity),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PawPrintPainter extends CustomPainter {
  _PawPrintPainter({required this.color});

  final Color color;

  // Posiciones relativas (0..1), tamaño y rotación de cada huella.
  static const List<({double x, double y, double size, double angle})> _paws = [
    (x: 0.10, y: 0.12, size: 34, angle: -0.3),
    (x: 0.82, y: 0.08, size: 26, angle: 0.4),
    (x: 0.68, y: 0.30, size: 40, angle: 0.1),
    (x: 0.22, y: 0.46, size: 28, angle: 0.5),
    (x: 0.90, y: 0.55, size: 32, angle: -0.2),
    (x: 0.45, y: 0.66, size: 22, angle: 0.2),
    (x: 0.12, y: 0.82, size: 36, angle: 0.3),
    (x: 0.74, y: 0.86, size: 28, angle: -0.4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final paw in _paws) {
      canvas.save();
      canvas.translate(paw.x * size.width, paw.y * size.height);
      canvas.rotate(paw.angle);
      _drawPaw(canvas, paint, paw.size);
      canvas.restore();
    }
  }

  void _drawPaw(Canvas canvas, Paint paint, double s) {
    final unit = s / 40;
    // Almohadilla central.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 6 * unit),
        width: 20 * unit,
        height: 16 * unit,
      ),
      paint,
    );
    // Cuatro dedos.
    const toes = [
      Offset(-10, -6),
      Offset(-3.5, -11),
      Offset(3.5, -11),
      Offset(10, -6),
    ];
    for (final toe in toes) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(toe.dx * unit, toe.dy * unit),
          width: 7 * unit,
          height: 9 * unit,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PawPrintPainter oldDelegate) =>
      oldDelegate.color != color;
}
