import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Comparador "Antes y Ahora" con un divisor que se arrastra para revelar.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    this.height = 200,
  });

  final Widget before;
  final Widget after;
  final double height;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _pos = 0.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final dividerX = width * _pos;
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _pos = (details.localPosition.dx / width).clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: [
                  // Capa "Ahora" (fondo completo).
                  Positioned.fill(child: widget.after),
                  const _CornerLabel(
                    label: 'Ahora',
                    alignment: Alignment.topRight,
                  ),
                  // Capa "Antes" recortada hasta el divisor.
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _LeftClipper(_pos),
                      child: widget.before,
                    ),
                  ),
                  if (_pos > 0.18)
                    const _CornerLabel(
                      label: 'Antes',
                      alignment: Alignment.topLeft,
                    ),
                  // Divisor + handle.
                  Positioned(
                    left: dividerX - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white),
                  ),
                  Positioned(
                    left: dividerX - 18,
                    top: widget.height / 2 - 18,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.drag_indicator,
                          color: AppColors.growth, size: 20),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _CornerLabel extends StatelessWidget {
  const _CornerLabel({required this.label, required this.alignment});

  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
