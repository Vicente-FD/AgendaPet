import 'package:agenda_pet/core/mocks/care_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/category_screen_layout.dart';
import 'package:flutter/material.dart';

class VaccinesScreen extends StatelessWidget {
  const VaccinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreenLayout(
      title: 'Vacunas',
      subtitle: 'Calendario de vacunación y desparasitación',
      icon: Icons.vaccines_outlined,
      color: AppColors.actionVaccines,
      items: CareMockData.vaccineItems,
      addButtonLabel: 'Registrar vacuna',
      onAddPressed: () => context.goAddVaccine(),
    );
  }
}
