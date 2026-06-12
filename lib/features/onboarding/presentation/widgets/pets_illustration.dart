import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Ilustración placeholder de mascotas para la pantalla de bienvenida.
class PetsIllustration extends StatelessWidget {
  const PetsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          const Positioned(
            left: 60,
            bottom: 30,
            child: _PetAvatar(
              icon: Icons.pets,
              color: Color(0xFF8D6E63),
              size: 90,
            ),
          ),
          const Positioned(
            right: 60,
            bottom: 40,
            child: _PetAvatar(
              icon: Icons.pets,
              color: Color(0xFFFF8F00),
              size: 70,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}
