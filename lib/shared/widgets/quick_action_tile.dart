import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/shared/widgets/pressable.dart';
import 'package:flutter/material.dart';

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final radius = BorderRadius.circular(16);

    return Pressable(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: radius,
          // En oscuro las sombras no se ven: damos definición con un borde sutil.
          border: isDark ? Border.all(color: context.surfaceMuted) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            // Sin tinte de hover (en web se "pegaba" y dejaba una card con otro
            // tono); el feedback ya lo dan la sombra, el encogido y el ripple.
            hoverColor: Colors.transparent,
            splashColor: color.withValues(alpha: 0.12),
            highlightColor: color.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  // OJO: nada de Flexible/Expanded aquí. Este tile también se usa
                  // dentro de un Row (Eventos/Familia) que entrega alto no acotado;
                  // un hijo con flex revienta el layout ("unbounded height").
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
