import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:agenda_pet/features/care/presentation/care_category_screen.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CareCategoryScreen(
      type: CareType.service,
      title: 'Servicios',
      subtitle: 'Baños, peluquería y visitas al veterinario',
      emptyMessage: 'Todavía no registras servicios.',
      addButtonLabel: 'Registrar servicio',
      onAddPressed: () => context.goAddService(),
    );
  }
}
