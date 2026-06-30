import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Métrica de paseo (distancia, tiempo, ritmo…). Se expande en una fila.
class WalkStat extends StatelessWidget {
  const WalkStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.walk,
    this.onSurface = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  /// true cuando va sobre un degradado (texto en blanco).
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final valueColor = onSurface ? Colors.white : null;
    final labelColor =
        onSurface ? Colors.white.withValues(alpha: 0.85) : AppColors.textSecondary;
    final iconColor = onSurface ? Colors.white : color;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}
