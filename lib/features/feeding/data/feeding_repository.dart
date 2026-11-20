import 'package:agenda_pet/core/api/api_client.dart';
import 'package:agenda_pet/features/feeding/data/feeding_dto.dart';
import 'package:dio/dio.dart';

/// Contrato de acceso al plan de alimentación de una mascota.
abstract interface class FeedingRepository {
  Future<List<FeedingDto>> list(String petId);
  Future<FeedingDto> create(String petId, FeedingDto plan);
  Future<void> delete(String petId, String id);
}

/// Implementación en memoria, para que la app funcione sin backend.
class MockFeedingRepository implements FeedingRepository {
  static final Map<String, List<FeedingDto>> _porMascota = {};
  static int _nextId = 0;

  static List<FeedingDto> _seed() => [
    FeedingDto(
      id: 'mock-f${_nextId++}',
      foodName: 'Adulto Razas Medianas',
      brand: 'ProPlan',
      kind: 'DRY',
      bagSizeKg: 7.5,
      dailyGrams: 290,
      activity: 'NORMAL',
      openedAt: DateTime.now().subtract(const Duration(days: 17)),
    ),
  ];

  List<FeedingDto> _lista(String petId) =>
      _porMascota.putIfAbsent(petId, _seed);

  @override
  Future<List<FeedingDto>> list(String petId) async =>
      List.unmodifiable(_lista(petId));

  @override
  Future<FeedingDto> create(String petId, FeedingDto plan) async {
    final creado = FeedingDto(
      id: 'mock-f${_nextId++}',
      foodName: plan.foodName,
      brand: plan.brand,
      kind: plan.kind,
      bagSizeKg: plan.bagSizeKg,
      dailyGrams: plan.dailyGrams,
      activity: plan.activity,
      openedAt: plan.openedAt,
    );
    _lista(petId).insert(0, creado);
    return creado;
  }

  @override
  Future<void> delete(String petId, String id) async {
    _porMascota[petId]?.removeWhere((p) => p.id == id);
  }
}

/// API real: `/pets/:petId/feeding`.
class ApiFeedingRepository implements FeedingRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<FeedingDto>> list(String petId) async {
    final res = await _dio.get('/pets/$petId/feeding');
    final items = (res.data['plans'] as List).cast<Map<String, dynamic>>();
    return items.map(FeedingDto.fromJson).toList();
  }

  @override
  Future<FeedingDto> create(String petId, FeedingDto plan) async {
    final res = await _dio.post('/pets/$petId/feeding', data: plan.toJson());
    return FeedingDto.fromJson(res.data['plan'] as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String petId, String id) =>
      _dio.delete('/pets/$petId/feeding/$id');
}
