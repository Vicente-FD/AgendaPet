import 'package:agenda_pet/core/data/repositories.dart';
import 'package:agenda_pet/features/pets/data/pet_dto.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

/// Mascotas de la cuenta, compartidas por el inicio, el selector y la lista.
///
/// Las pantallas escuchan con `ListenableBuilder`; al crear o borrar una
/// mascota se refrescan solas.
class PetsStore extends ChangeNotifier {
  PetsStore._();
  static final PetsStore instance = PetsStore._();

  List<PetDto> _pets = const [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  int _selectedIndex = 0;

  List<PetDto> get pets => _pets;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;
  bool get isEmpty => _loaded && _pets.isEmpty;

  int get selectedIndex =>
      _pets.isEmpty ? 0 : _selectedIndex.clamp(0, _pets.length - 1);
  PetDto? get selected => _pets.isEmpty ? null : _pets[selectedIndex];

  void select(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> load({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _pets = await Repositories.pets.list();
      _loaded = true;
    } catch (e) {
      _error = mensajeDeError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Crea la mascota y la deja seleccionada.
  Future<PetDto> add(PetDto pet) async {
    final creada = await Repositories.pets.create(pet);
    _pets = [..._pets, creada];
    _loaded = true;
    _selectedIndex = _pets.length - 1;
    notifyListeners();
    return creada;
  }

  /// Sube la foto de una mascota y actualiza la lista.
  Future<void> subirFoto(String id, Uint8List bytes) async {
    final actualizada = await Repositories.pets.uploadPhoto(id, bytes);
    _pets = [for (final p in _pets) p.id == id ? actualizada : p];
    notifyListeners();
  }

  /// Limpia los datos en memoria (cierre de sesión o borrado de cuenta).
  void reset() {
    _pets = const [];
    _loaded = false;
    _loading = false;
    _error = null;
    _selectedIndex = 0;
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await Repositories.pets.delete(id);
    _pets = _pets.where((p) => p.id != id).toList();
    notifyListeners();
  }
}

/// Traduce errores de red a algo que el usuario pueda entender.
String mensajeDeError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      return (data['error']['message'] as String?) ??
          'No se pudo completar la acción';
    }
    if (error.response?.statusCode == 401) {
      return 'Tu sesión expiró. Vuelve a iniciar sesión.';
    }
    return 'No se pudo conectar con el servidor';
  }
  return 'Ocurrió un error inesperado';
}
