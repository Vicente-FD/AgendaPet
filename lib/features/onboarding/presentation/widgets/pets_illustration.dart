import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Ilustración amigable de la pantalla de bienvenida: un perro y un gato
/// sobre un pequeño prado verde.
class PetsIllustration extends StatelessWidget {
  const PetsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Prado / sombra suave.
          Container(
            width: 260,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          // Acento de huella detrás.
          Positioned(
            top: 6,
            right: 36,
            child: Icon(
              Icons.pets,
              size: 26,
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: 30,
            left: 28,
            child: Icon(
              Icons.favorite,
              size: 18,
              color: AppColors.memories.withValues(alpha: 0.3),
            ),
          ),
          // Perro (más grande) y gato (más pequeño).
          const Positioned(
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PetBubble(
                  emoji: '🐶',
                  size: 132,
                  background: Color(0xFFE8F5E9),
                  border: AppColors.primary,
                ),
                SizedBox(width: 12),
                _PetBubble(
                  emoji: '🐱',
                  size: 104,
                  background: Color(0xFFFFF3E0),
                  border: Color(0xFFFF8F00),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetBubble extends StatelessWidget {
  const _PetBubble({
    required this.emoji,
    required this.size,
    required this.background,
    required this.border,
  });

  final String emoji;
  final double size;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: border.withValues(alpha: 0.35), width: 3),
        boxShadow: [
          BoxShadow(
            color: border.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
