import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Consejo curado para el cuidado de la mascota.
class PetTip {
  const PetTip({
    required this.title,
    required this.body,
    required this.category,
    this.icon = Icons.lightbulb_outline,
    this.color = AppColors.tips,
  });

  final String title;
  final String body;
  final String category;
  final IconData icon;
  final Color color;
}

abstract final class TipsMockData {
  /// Consejo destacado del día (se muestra en el dashboard).
  static const PetTip tipOfTheDay = PetTip(
    title: 'Tip del día',
    body:
        'Mantén siempre agua fresca y limpia disponible. En verano, cámbiala '
        'al menos dos veces al día para evitar el calor y la deshidratación.',
    category: 'Cuidados',
    icon: Icons.tips_and_updates_outlined,
    color: AppColors.tips,
  );

  static const List<PetTip> tips = [
    PetTip(
      title: '¿Cuándo esterilizar a una gata?',
      body:
          'Lo ideal es entre los 4 y 6 meses, antes del primer celo. Esto '
          'reduce el riesgo de tumores mamarios y evita camadas no deseadas. '
          'Consulta siempre con tu veterinario según el caso.',
      category: 'Esterilización',
      icon: Icons.health_and_safety_outlined,
      color: AppColors.actionVaccines,
    ),
    PetTip(
      title: 'Calendario de vacunas en cachorros',
      body:
          'Las primeras vacunas comienzan a las 6–8 semanas, con refuerzos cada '
          '3–4 semanas hasta los 4 meses. La antirrábica suele aplicarse a los '
          '3 meses.',
      category: 'Salud',
      icon: Icons.vaccines_outlined,
      color: AppColors.actionMedicines,
    ),
    PetTip(
      title: 'Frecuencia de baños en perros',
      body:
          'Un baño cada 3–4 semanas suele ser suficiente. Bañarlos en exceso '
          'reseca la piel y elimina la grasa protectora natural del pelaje.',
      category: 'Higiene',
      icon: Icons.shower_outlined,
      color: AppColors.actionCalendar,
    ),
    PetTip(
      title: 'Desparasitación interna',
      body:
          'En adultos se recomienda cada 3 meses. En cachorros, cada 15 días '
          'hasta los 2 meses y luego mensual hasta los 6 meses.',
      category: 'Salud',
      icon: Icons.medication_outlined,
      color: AppColors.actionMedicines,
    ),
    PetTip(
      title: 'Alimentación según la edad',
      body:
          'Los cachorros necesitan alimento rico en proteínas y varias comidas '
          'al día. En adultos, raciona según peso y actividad para evitar el '
          'sobrepeso.',
      category: 'Alimentación',
      icon: Icons.restaurant_outlined,
      color: AppColors.actionServices,
    ),
    PetTip(
      title: 'Señales de estrés en gatos',
      body:
          'Esconderse, dejar de comer, maullidos excesivos o acicalarse en '
          'exceso pueden indicar estrés. Mantén rutinas y espacios seguros.',
      category: 'Comportamiento',
      icon: Icons.psychology_outlined,
      color: AppColors.family,
    ),
  ];
}
