import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Integrante de la familia que administra la misma mascota.
class FamilyMember {
  const FamilyMember({
    required this.name,
    required this.role,
    required this.relation,
    required this.avatarColor,
    this.isOwner = false,
    this.pending = false,
  });

  final String name;
  final String role; // Administrador / Editor / Visualizador
  final String relation; // Mamá, Papá, Hijo/a…
  final Color avatarColor;
  final bool isOwner;
  final bool pending; // invitación enviada, aún sin aceptar
}

abstract final class FamilyMockData {
  static const String petName = 'Carolina';

  static const List<FamilyMember> members = [
    FamilyMember(
      name: 'María',
      role: 'Administradora',
      relation: 'Mamá',
      avatarColor: AppColors.primary,
      isOwner: true,
    ),
    FamilyMember(
      name: 'Jorge',
      role: 'Editor',
      relation: 'Papá',
      avatarColor: AppColors.actionCalendar,
    ),
    FamilyMember(
      name: 'Sofía',
      role: 'Visualizador',
      relation: 'Hija',
      avatarColor: AppColors.memories,
    ),
    FamilyMember(
      name: 'benjamin@correo.cl',
      role: 'Editor',
      relation: 'Invitación enviada',
      avatarColor: AppColors.textSecondary,
      pending: true,
    ),
  ];
}
