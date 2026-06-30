import 'dart:math' as math;

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Mapa estilizado con el recorrido de un paseo. No usa un mapa real (es
/// frontend): dibuja un fondo tipo mapa (calles, parques, agua) y encima la
/// ruta. Para el paseo en vivo se pasa [progressAnimation]; así SOLO el
/// marcador se repinta cada frame (el fondo y la ruta se dibujan una vez),
/// evitando el repintado completo a 60fps que congelaba la web.
class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    required this.points,
    this.color = AppColors.walk,
    this.progress,
    this.progressAnimation,
    this.height = 200,
    this.borderRadius = 16,
  });

  final List<Offset> points;
  final Color color;

  /// Progreso fijo 0..1 (registro). null = ruta completa.
  final double? progress;

  /// Progreso animado para el paseo en vivo (tiene prioridad sobre [progress]).
  final Animation<double>? progressAnimation;

  /// Alto fijo; si es null, ocupa todo el espacio disponible.
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLive = progressAnimation != null;

    // Capa base (fondo + ruta). Estática: se aísla con RepaintBoundary y no se
    // repinta mientras corre la animación del marcador.
    Widget map = RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _BasePainter(
          points: points,
          color: color,
          progress: isLive ? null : progress,
          isDark: isDark,
        ),
      ),
    );

    // Capa del marcador en vivo: se repinta sola con la animación.
    if (isLive) {
      map = Stack(
        fit: StackFit.expand,
        children: [
          map,
          CustomPaint(
            size: Size.infinite,
            painter: _MarkerPainter(
              points: points,
              color: color,
              progress: progressAnimation!,
            ),
          ),
        ],
      );
    }

    // El mapa es decorativo: nunca participa del hit-test (ni del mouse).
    map = IgnorePointer(child: map);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: height == null
          ? SizedBox.expand(child: map)
          : SizedBox(height: height, width: double.infinity, child: map),
    );
  }
}

/// Convierte puntos normalizados (0..1) a píxeles dentro de un rect con margen.
List<Offset> _toPixels(List<Offset> points, Size size) {
  const pad = 18.0;
  final rect = Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2);
  return [
    for (final p in points)
      Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height),
  ];
}

Path _pathThrough(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[i];
    final p1 = pts[i + 1];
    final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
    path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
  }
  path.lineTo(pts.last.dx, pts.last.dy);
  return path;
}

/// Punto sobre la polilínea a la fracción [t] (0..1).
Offset _pointAt(List<Offset> pts, double t) {
  if (pts.length < 2) return pts.first;
  var total = 0.0;
  final seg = <double>[];
  for (var i = 0; i < pts.length - 1; i++) {
    final d = (pts[i + 1] - pts[i]).distance;
    seg.add(d);
    total += d;
  }
  final target = total * t.clamp(0.0, 1.0);
  var acc = 0.0;
  for (var i = 0; i < pts.length - 1; i++) {
    if (acc + seg[i] >= target) {
      final f = seg[i] == 0 ? 0.0 : (target - acc) / seg[i];
      return Offset.lerp(pts[i], pts[i + 1], f)!;
    }
    acc += seg[i];
  }
  return pts.last;
}

void _strokePath(Canvas canvas, Path path, Color c, double width) {
  // "Glow" barato: un trazo más ancho y translúcido detrás (sin MaskFilter,
  // que es caro/inestable en Flutter web).
  canvas.drawPath(
    path,
    Paint()
      ..color = c.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawPath(
    path,
    Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

/// Pinta el fondo tipo mapa y la ruta. Estático (shouldRepaint por datos).
class _BasePainter extends CustomPainter {
  _BasePainter({
    required this.points,
    required this.color,
    required this.progress,
    required this.isDark,
  });

  final List<Offset> points;
  final Color color;
  final double? progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _paintBackground(canvas, size);

    final pts = _toPixels(points, size);
    if (pts.length < 2) return;
    final full = _pathThrough(pts);

    if (progress == null) {
      _strokePath(canvas, full, color, 6);
      _drawEndpoint(canvas, pts.first, const Color(0xFF2ECC71));
      _drawFlag(canvas, pts.last);
    } else {
      // Caso registro con progreso fijo (no se usa en vivo).
      _strokePath(canvas, full, color.withValues(alpha: 0.25), 6);
      _drawEndpoint(canvas, pts.first, const Color(0xFF2ECC71));
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    final base = Paint()
      ..color = isDark ? const Color(0xFF1B2430) : const Color(0xFFE9F0F5);
    canvas.drawRect(Offset.zero & size, base);

    final park = Paint()
      ..color = isDark ? const Color(0xFF22372B) : const Color(0xFFD6EAD7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.55, size.width * 0.34,
            size.height * 0.34),
        const Radius.circular(14),
      ),
      park,
    );
    canvas.drawCircle(
        Offset(size.width * 0.82, size.height * 0.2), size.width * 0.13, park);

    final water = Paint()
      ..color = isDark ? const Color(0xFF1E3A4C) : const Color(0xFFC9E4F2);
    final waterPath = Path()
      ..moveTo(size.width * 0.62, 0)
      ..quadraticBezierTo(size.width * 0.74, size.height * 0.22,
          size.width * 0.66, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.58, size.height * 0.6,
          size.width * 0.74, size.height * 0.74)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waterPath, water);

    final street = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 6;
    for (var i = 1; i <= 3; i++) {
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), street);
    }
    for (var i = 1; i <= 3; i++) {
      final dx = size.width * i / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), street);
    }
  }

  void _drawEndpoint(Canvas canvas, Offset c, Color ringColor) {
    canvas.drawCircle(c, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
        c,
        8,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawCircle(c, 3.5, Paint()..color = ringColor);
  }

  void _drawFlag(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 9, Paint()..color = Colors.white);
    canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = AppColors.actionServices
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    final path = Path()
      ..moveTo(c.dx - 1.5, c.dy - 4)
      ..lineTo(c.dx + 4, c.dy - 2)
      ..lineTo(c.dx - 1.5, c.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.actionServices);
  }

  @override
  bool shouldRepaint(_BasePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.isDark != isDark ||
      old.points != points;
}

/// Pinta SOLO el tramo recorrido + el marcador en movimiento. Se repinta con la
/// animación (repaint), sin reconstruir widgets ni el fondo.
class _MarkerPainter extends CustomPainter {
  _MarkerPainter({
    required this.points,
    required this.color,
    required this.progress,
  }) : super(repaint: progress);

  final List<Offset> points;
  final Color color;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final pts = _toPixels(points, size);
    if (pts.length < 2) return;

    final t = progress.value.clamp(0.0, 1.0);
    final marker = _pointAt(pts, t);

    // Tramo recorrido (resaltado) hasta el marcador.
    final traveled = Path()..moveTo(pts.first.dx, pts.first.dy);
    var total = 0.0;
    final seg = <double>[];
    for (var i = 0; i < pts.length - 1; i++) {
      final d = (pts[i + 1] - pts[i]).distance;
      seg.add(d);
      total += d;
    }
    final target = total * t;
    var acc = 0.0;
    for (var i = 0; i < pts.length - 1; i++) {
      if (acc + seg[i] >= target) {
        traveled.lineTo(marker.dx, marker.dy);
        break;
      }
      acc += seg[i];
      traveled.lineTo(pts[i + 1].dx, pts[i + 1].dy);
    }
    canvas.drawPath(
      traveled,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Marcador.
    canvas.drawCircle(marker, 16, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(marker, 10, Paint()..color = Colors.white);
    canvas.drawCircle(
        marker,
        10,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawCircle(marker, 4.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkerPainter old) =>
      old.points != points || old.color != color;
}

/// Pequeño indicador "EN VIVO" con punto pulsante. Reutilizable.
class LivePulseDot extends StatelessWidget {
  const LivePulseDot({super.key, required this.t, this.color = Colors.red});

  /// Valor 0..1 que controla el pulso (normalmente de un AnimationController).
  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 6 + pulse * 8,
            height: 6 + pulse * 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25 * (1 - pulse)),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}
