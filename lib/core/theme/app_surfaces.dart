import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Colores de superficie que se resuelven según el brillo del tema, para que
/// el modo oscuro se vea bien sin reescribir cada widget.
///
/// El texto secundario (`AppColors.textSecondary`, gris medio) y los colores de
/// marca/acento funcionan en ambos modos, así que no hace falta cambiarlos.
extension AppSurfaces on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Fondo de tarjetas, app bars y tiles (blanco en claro).
  Color get surface => isDarkMode ? AppColors.darkSurface : AppColors.background;

  /// Relleno de campos, chips y bordes suaves (gris muy claro en claro).
  Color get surfaceMuted =>
      isDarkMode ? AppColors.darkSurfaceMuted : AppColors.surfaceCard;

  /// Fondo general del Scaffold.
  Color get scaffold =>
      isDarkMode ? AppColors.darkScaffold : AppColors.scaffoldBackground;
}
