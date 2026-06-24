import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Un evento significativo / recuerdo de la mascota (cumpleaños, primera vez…).
class SignificantEvent {
  const SignificantEvent({
    required this.title,
    required this.dateLabel,
    required this.note,
    this.icon = Icons.celebration_outlined,
    this.color = AppColors.memories,
    this.imageBytes,
  });

  final String title;
  final String dateLabel;
  final String note;
  final IconData icon;
  final Color color;
  final Uint8List? imageBytes;
}

abstract final class EventsMockData {
  static final List<SignificantEvent> events = [
    const SignificantEvent(
      title: '¡Feliz cumpleaños, Carolina!',
      dateLabel: '20 de octubre 2025',
      note: 'Cumplió 2 años con torta de premios para perros.',
      icon: Icons.cake_outlined,
      color: AppColors.memories,
    ),
    const SignificantEvent(
      title: 'Primera vacuna',
      dateLabel: '5 de agosto 2024',
      note: 'Octuple aplicada en Clínica VetPet. ¡Muy valiente!',
      icon: Icons.vaccines_outlined,
      color: AppColors.actionVaccines,
    ),
    const SignificantEvent(
      title: 'Primer baño',
      dateLabel: '28 de julio 2024',
      note: 'No le gustó el agua, pero quedó suavecita.',
      icon: Icons.shower_outlined,
      color: AppColors.actionCalendar,
    ),
    const SignificantEvent(
      title: 'Llegada a casa',
      dateLabel: '12 de julio 2024',
      note: 'El día que Carolina se convirtió en parte de la familia ❤️',
      icon: Icons.home_outlined,
      color: AppColors.primary,
    ),
  ];
}
