import 'package:agenda_pet/core/mocks/care_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/category_screen_layout.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreenLayout(
      title: 'Servicios',
      subtitle: 'Peluquería, clínica y hospedaje',
      icon: Icons.home_repair_service_outlined,
      color: AppColors.actionServices,
      items: CareMockData.serviceItems,
      addButtonLabel: 'Agregar servicio',
      onAddPressed: () => context.goAddService(),
    );
  }
}
