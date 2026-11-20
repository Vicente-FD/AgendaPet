import 'package:agenda_pet/core/api/api_client.dart';
import 'package:agenda_pet/features/reminders/data/reminder_dto.dart';
import 'package:dio/dio.dart';

/// Contrato de acceso a los recordatorios de una mascota.
abstract interface class RemindersRepository {
  Future<List<ReminderDto>> list(String petId);
  Future<ReminderDto> create(String petId, ReminderDto reminder);
  Future<ReminderDto> setDone(String petId, String id, {required bool done});
  Future<void> delete(String petId, String id);
}

/// Implementación en memoria, para que la app funcione sin backend.
class MockRemindersRepository implements RemindersRepository {
  static final Map<String, List<ReminderDto>> _porMascota = {};
  static int _nextId = 0;

  static List<ReminderDto> _seed() {
    final hoy = DateTime.now();
    final base = DateTime(hoy.year, hoy.month, hoy.day);
    return [
      ReminderDto(
        id: 'mock-r${_nextId++}',
        title: 'Baño',
        type: 'Servicio',
        dueAt: base.add(const Duration(days: 1, hours: 16)),
      ),
      ReminderDto(
        id: 'mock-r${_nextId++}',
        title: 'Vacuna Rabia',
        type: 'Vacuna',
        dueAt: base.add(const Duration(days: 8, hours: 10)),
      ),
    ];
  }

  List<ReminderDto> _lista(String petId) =>
      _porMascota.putIfAbsent(petId, _seed);

  @override
  Future<List<ReminderDto>> list(String petId) async {
    final lista = _lista(petId)..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return List.unmodifiable(lista);
  }

  @override
  Future<ReminderDto> create(String petId, ReminderDto reminder) async {
    final creado = ReminderDto(
      id: 'mock-r${_nextId++}',
      title: reminder.title,
      dueAt: reminder.dueAt,
      type: reminder.type,
      done: reminder.done,
    );
    _lista(petId).add(creado);
    return creado;
  }

  @override
  Future<ReminderDto> setDone(
    String petId,
    String id, {
    required bool done,
  }) async {
    final lista = _lista(petId);
    final i = lista.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Recordatorio no encontrado');
    final actualizado = ReminderDto(
      id: lista[i].id,
      title: lista[i].title,
      dueAt: lista[i].dueAt,
      type: lista[i].type,
      done: done,
    );
    lista[i] = actualizado;
    return actualizado;
  }

  @override
  Future<void> delete(String petId, String id) async {
    _porMascota[petId]?.removeWhere((r) => r.id == id);
  }
}

/// API real: `/pets/:petId/reminders`.
class ApiRemindersRepository implements RemindersRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<ReminderDto>> list(String petId) async {
    final res = await _dio.get('/pets/$petId/reminders');
    final items = (res.data['reminders'] as List).cast<Map<String, dynamic>>();
    return items.map(ReminderDto.fromJson).toList();
  }

  @override
  Future<ReminderDto> create(String petId, ReminderDto reminder) async {
    final res = await _dio.post(
      '/pets/$petId/reminders',
      data: reminder.toJson(),
    );
    return ReminderDto.fromJson(res.data['reminder'] as Map<String, dynamic>);
  }

  @override
  Future<ReminderDto> setDone(
    String petId,
    String id, {
    required bool done,
  }) async {
    final res = await _dio.patch(
      '/pets/$petId/reminders/$id',
      data: {'done': done},
    );
    return ReminderDto.fromJson(res.data['reminder'] as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String petId, String id) =>
      _dio.delete('/pets/$petId/reminders/$id');
}
