import 'package:agenda_pet/core/data/repositories.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/features/feeding/data/feeding_dto.dart';
import 'package:flutter/foundation.dart';

/// Plan de alimentación de la mascota seleccionada.
class FeedingStore extends ChangeNotifier {
  FeedingStore._();
  static final FeedingStore instance = FeedingStore._();

  String? _petId;
  List<FeedingDto> _items = const [];
  bool _loading = false;
  String? _error;

  List<FeedingDto> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  /// El plan vigente es el último registrado.
  FeedingDto? get actual => _items.isEmpty ? null : _items.first;

  Future<void> loadFor(String petId, {bool force = false}) async {
    if (_loading) return;
    if (_petId == petId && !force) return;
    _petId = petId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await Repositories.feeding.list(petId);
    } catch (e) {
      _error = mensajeDeError(e);
      _items = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadForSelected({bool force = false}) async {
    final mascota = PetsStore.instance.selected;
    if (mascota == null) return;
    await loadFor(mascota.id, force: force);
  }

  Future<FeedingDto> add(String petId, FeedingDto plan) async {
    final creado = await Repositories.feeding.create(petId, plan);
    if (_petId == petId) {
      _items = [creado, ..._items];
      notifyListeners();
    }
    return creado;
  }

  void reset() {
    _petId = null;
    _items = const [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
