import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Helper para elegir una imagen y devolverla como bytes.
///
/// Usamos bytes (no rutas de archivo) para que funcione igual en web y móvil.
abstract final class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Abre la galería y devuelve los bytes de la imagen elegida, o `null` si se cancela.
  static Future<Uint8List?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }

  /// Abre la cámara y devuelve los bytes de la foto tomada, o `null` si se cancela.
  static Future<Uint8List?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }
}
