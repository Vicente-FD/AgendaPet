import 'package:agenda_pet/core/mocks/care_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/category_screen_layout.dart';
import 'package:flutter/material.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryScreenLayout(
      title: 'Medicinas',
      subtitle: 'Tratamientos y medicación activa',
      icon: Icons.medication_outlined,
      color: AppColors.actionMedicines,
      items: CareMockData.medicineItems,
      addButtonLabel: 'Agregar medicina',
    );
  }
}
