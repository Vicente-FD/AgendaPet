import 'package:agenda_pet/core/api/api_client.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:dio/dio.dart';

/// Contrato de acceso a los registros de cuidado de una mascota.
abstract interface class CareRepository {
  Future<List<CareDto>> list(String petId, {CareType? type});
  Future<CareDto> create(String petId, CareDto record);
  Future<void> delete(String petId, String id);
}

/// Implementación en memoria, para que la app funcione sin backend.
class MockCareRepository implements CareRepository {
  static final Map<String, List<CareDto>> _porMascota = {};
  static int _nextId = 0;

  static List<CareDto> _seed() {
    final hoy = DateTime.now();
    return [
      CareDto(
        id: 'mock-c${_nextId++}',
        type: CareType.vaccine,
        name: 'Vacuna Rabia',
        date: hoy.subtract(const Duration(days: 180)),
        nextDueDate: hoy.add(const Duration(days: 185)),
      ),
      CareDto(
        id: 'mock-c${_nextId++}',
        type: CareType.vaccine,
        name: 'Séxtuple',
        date: hoy.subtract(const Duration(days: 300)),
        nextDueDate: hoy.subtract(const Duration(days: 10)),
      ),
      CareDto(
        id: 'mock-c${_nextId++}',
        type: CareType.medicine,
        name: 'Antiparasitario',
        date: hoy.subtract(const Duration(days: 45)),
        nextDueDate: hoy.add(const Duration(days: 45)),
        notes: 'Una pastilla cada 3 meses',
      ),
      CareDto(
        id: 'mock-c${_nextId++}',
        type: CareType.service,
        name: 'Baño y corte',
        date: hoy.subtract(const Duration(days: 20)),
      ),
      CareDto(
        id: 'mock-c${_nextId++}',
        type: CareType.appointment,
        name: 'Control veterinario',
        date: hoy.add(const Duration(days: 12)),
      ),
    ];
  }

  List<CareDto> _lista(String petId) => _porMascota.putIfAbsent(petId, _seed);

  @override
  Future<List<CareDto>> list(String petId, {CareType? type}) async {
    final lista = _lista(petId)
        .where((r) => type == null || r.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(lista);
  }

  @override
  Future<CareDto> create(String petId, CareDto record) async {
    final creado = CareDto(
      id: 'mock-c${_nextId++}',
      type: record.type,
      name: record.name,
      date: record.date,
      nextDueDate: record.nextDueDate,
      notes: record.notes,
    );
    _lista(petId).add(creado);
    return creado;
  }

  @override
  Future<void> delete(String petId, String id) async {
    _porMascota[petId]?.removeWhere((r) => r.id == id);
  }
}

/// API real: `/pets/:petId/care`.
class ApiCareRepository implements CareRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<CareDto>> list(String petId, {CareType? type}) async {
    final res = await _dio.get(
      '/pets/$petId/care',
      queryParameters: {if (type != null) 'type': type.api},
    );
    final items = (res.data['records'] as List).cast<Map<String, dynamic>>();
    return items.map(CareDto.fromJson).toList();
  }

  @override
  Future<CareDto> create(String petId, CareDto record) async {
    final res = await _dio.post('/pets/$petId/care', data: record.toJson());
    return CareDto.fromJson(res.data['record'] as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String petId, String id) =>
      _dio.delete('/pets/$petId/care/$id');
}
