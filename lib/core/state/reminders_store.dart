import 'package:agenda_pet/core/data/repositories.dart';
import 'package:agenda_pet/core/notifications/local_notifications.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/features/reminders/data/reminder_dto.dart';
import 'package:flutter/foundation.dart';

/// Recordatorios de la mascota seleccionada.
class RemindersStore extends ChangeNotifier {
  RemindersStore._();
  static final RemindersStore instance = RemindersStore._();

  String? _petId;
  List<ReminderDto> _items = const [];
  bool _loading = false;
  String? _error;

  List<ReminderDto> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  /// Pendientes ordenados por fecha, que es lo que muestra el inicio.
  List<ReminderDto> get upcoming =>
      _items.where((r) => !r.done).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  int get pendingCount => _items.where((r) => !r.done).length;

  /// Reprograma los avisos de los recordatorios pendientes.
  Future<void> _sincronizarAvisos(String nombreMascota) async {
    for (final r in _items) {
      if (r.done) {
        await LocalNotifications.cancelar(r.id);
      } else {
        await LocalNotifications.programar(
          id: r.id,
          titulo: r.title,
          cuerpo: '$nombreMascota · ${r.whenLabel}',
          cuando: r.dueAt,
        );
      }
    }
  }

  Future<void> loadFor(String petId, {bool force = false}) async {
    if (_loading) return;
    if (_petId == petId && !force) return;
    final nombreMascota = PetsStore.instance.selected?.name ?? 'Tu mascota';
    _petId = petId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await Repositories.reminders.list(petId);
    } catch (e) {
      _error = mensajeDeError(e);
      _items = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
    await _sincronizarAvisos(nombreMascota);
  }

  Future<void> add(String petId, ReminderDto reminder) async {
    final creado = await Repositories.reminders.create(petId, reminder);
    if (_petId == petId) {
      _items = [..._items, creado];
      notifyListeners();
    }
    await LocalNotifications.programar(
      id: creado.id,
      titulo: creado.title,
      cuerpo: creado.whenLabel,
      cuando: creado.dueAt,
    );
  }

  Future<void> toggleDone(String petId, ReminderDto reminder) async {
    final actualizado = await Repositories.reminders
        .setDone(petId, reminder.id, done: !reminder.done);
    _items = [
      for (final r in _items) r.id == actualizado.id ? actualizado : r,
    ];
    notifyListeners();
    if (actualizado.done) {
      await LocalNotifications.cancelar(actualizado.id);
    } else {
      await LocalNotifications.programar(
        id: actualizado.id,
        titulo: actualizado.title,
        cuerpo: actualizado.whenLabel,
        cuando: actualizado.dueAt,
      );
    }
  }

  /// Limpia los datos en memoria (cierre de sesión o borrado de cuenta).
  void reset() {
    _petId = null;
    _items = const [];
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> remove(String petId, String id) async {
    await Repositories.reminders.delete(petId, id);
    _items = _items.where((r) => r.id != id).toList();
    notifyListeners();
    await LocalNotifications.cancelar(id);
  }
}
