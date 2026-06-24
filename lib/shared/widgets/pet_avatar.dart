import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Avatar circular de una mascota.
///
/// Muestra la foto (bytes) si existe; si no, un placeholder con icono de huella.
/// Si [onAddPhoto] no es nulo, dibuja una insignia de cámara para añadir/cambiar foto.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    this.imageBytes,
    this.radius = 48,
    this.backgroundColor,
    this.iconColor,
    this.onAddPhoto,
  });

  final Uint8List? imageBytes;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.15);
    final fg = iconColor ?? AppColors.primary;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
      child: imageBytes == null
          ? Icon(Icons.pets, size: radius * 0.9, color: fg)
          : null,
    );

    if (onAddPhoto == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onAddPhoto,
              child: Padding(
                padding: EdgeInsets.all(radius * 0.16),
                child: Icon(
                  imageBytes == null ? Icons.add_a_photo : Icons.edit,
                  size: radius * 0.32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
