import 'dart:convert';
import 'dart:typed_data';

import 'package:agenda_pet/core/api/api_client.dart';
import 'package:agenda_pet/core/mocks/pets_mock_data.dart';
import 'package:agenda_pet/features/pets/data/pet_dto.dart';
import 'package:dio/dio.dart';

/// Contrato de acceso a mascotas.
abstract interface class PetsRepository {
  Future<List<PetDto>> list();
  Future<PetDto> create(PetDto pet);
  Future<void> delete(String id);

  /// Sube la foto de la mascota y devuelve el registro actualizado.
  Future<PetDto> uploadPhoto(
    String id,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  });
}

/// Implementación en memoria: la app funciona y **guarda durante la sesión**
/// aunque el backend no esté levantado. Se reinicia al cerrar la app.
class MockPetsRepository implements PetsRepository {
  static final List<PetDto> _pets = [
    for (var i = 0; i < PetsMockData.pets.length; i++)
      PetDto(
        id: 'mock-$i',
        name: PetsMockData.pets[i].name,
        species: PetsMockData.pets[i].species,
        breed: PetsMockData.pets[i].breed,
        birthDate: DateTime.now().subtract(Duration(days: 365 * (i + 2))),
      ),
  ];

  static int _nextId = PetsMockData.pets.length;

  @override
  Future<List<PetDto>> list() async => List.unmodifiable(_pets);

  @override
  Future<PetDto> create(PetDto pet) async {
    final created = PetDto(
      id: 'mock-${_nextId++}',
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      birthDate: pet.birthDate,
      weightKg: pet.weightKg,
      avatarUrl: pet.avatarUrl,
    );
    _pets.add(created);
    return created;
  }

  @override
  Future<void> delete(String id) async {
    _pets.removeWhere((pet) => pet.id == id);
  }

  /// Sin backend la foto se queda en memoria; la pantalla la muestra igual.
  @override
  Future<PetDto> uploadPhoto(
    String id,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    fotosLocales[id] = bytes;
    return _pets.firstWhere((p) => p.id == id);
  }
}

/// Fotos elegidas que todavía no están en el servidor (modo sin backend).
final Map<String, Uint8List> fotosLocales = {};

/// API real: `/pets`.
class ApiPetsRepository implements PetsRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<PetDto>> list() async {
    final res = await _dio.get('/pets');
    final pets = (res.data['pets'] as List).cast<Map<String, dynamic>>();
    return pets.map(PetDto.fromJson).toList();
  }

  @override
  Future<PetDto> create(PetDto pet) async {
    final res = await _dio.post('/pets', data: pet.toJson());
    return PetDto.fromJson(res.data['pet'] as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id) => _dio.delete('/pets/$id');

  @override
  Future<PetDto> uploadPhoto(
    String id,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final res = await _dio.post(
      '/pets/$id/photo',
      data: {'data': base64Encode(bytes), 'contentType': contentType},
    );
    return PetDto.fromJson(res.data['pet'] as Map<String, dynamic>);
  }
}
