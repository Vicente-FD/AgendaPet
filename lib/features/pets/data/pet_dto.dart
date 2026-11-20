import 'package:agenda_pet/core/mocks/pets_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Mascota tal como la entrega la API (`GET /pets`).
class PetDto {
  const PetDto({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.weightKg,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final double? weightKg;
  final String? avatarUrl;

  factory PetDto.fromJson(Map<String, dynamic> json) => PetDto(
    id: json['id'] as String,
    name: json['name'] as String,
    species: json['species'] as String,
    breed: json['breed'] as String?,
    birthDate: json['birthDate'] == null
        ? null
        : DateTime.tryParse(json['birthDate'] as String),
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    avatarUrl: json['avatarUrl'] as String?,
  );

  /// Cuerpo que espera la API al crear o editar.
  Map<String, dynamic> toJson() => {
    'name': name,
    'species': species,
    if (breed != null && breed!.isNotEmpty) 'breed': breed,
    if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
    if (weightKg != null) 'weightKg': weightKg,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };

  /// Edad legible a partir de la fecha de nacimiento.
  String get ageLabel {
    final birth = birthDate;
    if (birth == null) return 'Edad no registrada';
    final now = DateTime.now();
    var months = (now.year - birth.year) * 12 + now.month - birth.month;
    if (now.day < birth.day) months--;
    if (months < 1) return 'Recién nacido';
    if (months < 24) return '$months ${months == 1 ? 'mes' : 'meses'}';
    final years = months ~/ 12;
    return '$years ${years == 1 ? 'año' : 'años'}';
  }

  static const _accents = [
    AppColors.primary,
    Color(0xFFFF8F00),
    AppColors.actionCalendar,
    AppColors.actionMedicines,
  ];

  /// Adapta la mascota al modelo que consumen las tarjetas y el selector.
  PetSummary toSummary({required int index, int pendingTasks = 0}) {
    return PetSummary(
      name: name,
      species: species,
      breed: breed == null || breed!.isEmpty ? 'Sin raza registrada' : breed!,
      age: ageLabel,
      pendingTasks: pendingTasks,
      accent: _accents[index % _accents.length],
      emoji: switch (species) {
        'Perro' => '\u{1F436}',
        'Gato' => '\u{1F431}',
        _ => '\u{1F43E}',
      },
    );
  }
}
