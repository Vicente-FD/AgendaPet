import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:agenda_pet/features/care/presentation/care_category_screen.dart';
import 'package:flutter/material.dart';

class VaccinesScreen extends StatelessWidget {
  const VaccinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CareCategoryScreen(
      type: CareType.vaccine,
      title: 'Vacunas',
      subtitle: 'Calendario de vacunación y desparasitación',
      emptyMessage: 'Todavía no registras vacunas.',
      addButtonLabel: 'Registrar vacuna',
      onAddPressed: () => context.goAddVaccine(),
    );
  }
}
