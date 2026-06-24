import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/core/utils/image_picker_helper.dart';
import 'package:flutter/material.dart';

/// Muestra una hoja inferior para elegir Cámara o Galería y devuelve los bytes.
Future<Uint8List?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<Uint8List?>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primary),
              title: const Text('Tomar foto'),
              onTap: () async {
                final bytes = await ImagePickerHelper.pickFromCamera();
                if (sheetContext.mounted) Navigator.pop(sheetContext, bytes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Elegir de la galería'),
              onTap: () async {
                final bytes = await ImagePickerHelper.pickFromGallery();
                if (sheetContext.mounted) Navigator.pop(sheetContext, bytes);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// Campo de formulario para añadir una foto. El padre guarda los bytes y los
/// pasa de vuelta; al tocar abre [showPhotoSourceSheet].
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.label,
    required this.imageBytes,
    required this.onChanged,
    this.height = 160,
    this.color = AppColors.primary,
  });

  final String label;
  final Uint8List? imageBytes;
  final ValueChanged<Uint8List?> onChanged;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Material(
          color: context.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final bytes = await showPhotoSourceSheet(context);
              if (bytes != null) onChanged(bytes);
            },
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: imageBytes != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(imageBytes!, fit: BoxFit.cover),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              tooltip: 'Quitar foto',
                              onPressed: () => onChanged(null),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: color, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Toca para añadir una foto',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
