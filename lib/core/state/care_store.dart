import 'package:agenda_pet/core/data/repositories.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:flutter/foundation.dart';

/// Registros de cuidado (vacunas, medicinas, servicios y citas) de la mascota
/// seleccionada. Se guardan todos juntos y se filtran por tipo al mostrarlos.
class CareStore extends ChangeNotifier {
  CareStore._();
  static final CareStore instance = CareStore._();

  String? _petId;
  List<CareDto> _items = const [];
  bool _loading = false;
  String? _error;

  List<CareDto> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  List<CareDto> byType(CareType type) =>
      _items.where((r) => r.type == type).toList();

  /// Pendientes: próximos controles ya vencidos o por vencer en 30 días.
  List<CareDto> get proximosControles {
    final limite = DateTime.now().add(const Duration(days: 30));
    return _items
        .where((r) => r.nextDueDate != null && r.nextDueDate!.isBefore(limite))
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  Future<void> loadFor(String petId, {bool force = false}) async {
    if (_loading) return;
    if (_petId == petId && !force) return;
    _petId = petId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await Repositories.care.list(petId);
    } catch (e) {
      _error = mensajeDeError(e);
      _items = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Carga los registros de la mascota seleccionada, si hay alguna.
  Future<void> loadForSelected({bool force = false}) async {
    final mascota = PetsStore.instance.selected;
    if (mascota == null) return;
    await loadFor(mascota.id, force: force);
  }

  Future<CareDto> add(String petId, CareDto record) async {
    final creado = await Repositories.care.create(petId, record);
    if (_petId == petId) {
      _items = [..._items, creado];
      notifyListeners();
    }
    return creado;
  }

  Future<void> remove(String petId, String id) async {
    await Repositories.care.delete(petId, id);
    _items = _items.where((r) => r.id != id).toList();
    notifyListeners();
  }

  /// Limpia los datos en memoria (cierre de sesión o borrado de cuenta).
  void reset() {
    _petId = null;
    _items = const [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
