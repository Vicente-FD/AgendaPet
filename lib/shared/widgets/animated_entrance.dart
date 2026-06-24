import 'package:flutter/material.dart';

/// Hace aparecer su hijo con un fundido + leve desplazamiento hacia arriba.
///
/// Pensado para entradas escalonadas: pasa un [delay] creciente por índice.
/// El retardo se implementa con un [Interval] sobre un único controlador (sin
/// `Timer`), así que se limpia solo y no deja temporizadores pendientes en tests.
/// Como sólo usa opacidad y un Transform (en fase de pintado), nunca provoca
/// desbordes de layout.
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 16,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;

  /// Helper para listas: aplica un retardo proporcional al índice (máx. 8).
  static Duration stagger(int index, {int stepMs = 60, int maxSteps = 8}) {
    final steps = index > maxSteps ? maxSteps : index;
    return Duration(milliseconds: steps * stepMs);
  }

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final startFraction = total.inMicroseconds == 0
        ? 0.0
        : widget.delay.inMicroseconds / total.inMicroseconds;
    _curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1, curve: Curves.easeOutCubic),
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
      animation: _curved,
      builder: (context, child) {
        return Opacity(
          opacity: _curved.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _curved.value) * widget.offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
