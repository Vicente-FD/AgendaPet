import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:agenda_pet/features/care/presentation/care_category_screen.dart';
import 'package:flutter/material.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CareCategoryScreen(
      type: CareType.medicine,
      title: 'Medicinas',
      subtitle: 'Tratamientos y antiparasitarios',
      emptyMessage: 'Todavía no registras medicinas.',
      addButtonLabel: 'Registrar medicina',
      onAddPressed: () => context.goAddMedicine(),
    );
  }
}
