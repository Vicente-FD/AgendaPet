import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Resumen de una mascota para el selector y la lista "Mis mascotas".
class PetSummary {
  const PetSummary({
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.pendingTasks,
    required this.accent,
    this.emoji = '🐶',
  });

  final String name;
  final String species;
  final String breed;
  final String age;
  final int pendingTasks;
  final Color accent;
  final String emoji;
}

abstract final class PetsMockData {
  static const List<PetSummary> pets = [
    PetSummary(
      name: 'Carolina',
      species: 'Perro',
      breed: 'Mestiza',
      age: '3 años',
      pendingTasks: 2,
      accent: AppColors.primary,
      emoji: '🐶',
    ),
    PetSummary(
      name: 'Michi',
      species: 'Gato',
      breed: 'Siamés',
      age: '2 años',
      pendingTasks: 1,
      accent: Color(0xFFFF8F00),
      emoji: '🐱',
    ),
    PetSummary(
      name: 'Rocky',
      species: 'Perro',
      breed: 'Labrador',
      age: '5 años',
      pendingTasks: 0,
      accent: AppColors.actionCalendar,
      emoji: '🐕',
    ),
  ];
}
