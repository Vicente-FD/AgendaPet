// Datos de prueba para vacunas, medicinas, servicios y perfil.
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MockCareItem {
  const MockCareItem({
    required this.title,
    required this.subtitle,
    this.detail,
    this.status,
    this.icon = Icons.event_outlined,
    this.iconColor = AppColors.actionCalendar,
  });

  final String title;
  final String subtitle;
  final String? detail;
  final String? status;
  final IconData icon;
  final Color iconColor;
}

class MockPetDetail {
  const MockPetDetail({
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.chip,
  });

  final String name;
  final String species;
  final String breed;
  final String age;
  final String weight;
  final String chip;
}

abstract final class CareMockData {
  static const MockPetDetail petDetail = MockPetDetail(
    name: 'Carolina',
    species: 'Perro',
    breed: 'Mestiza',
    age: '3 años',
    weight: '12 kg',
    chip: '985.123.456',
  );

  static const List<MockCareItem> agendaItems = [
    MockCareItem(
      title: 'Baño',
      subtitle: 'Mañana, martes 25 a las 16:00',
      detail: 'Peluquería Canina Happy Paws',
      status: 'Pendiente',
      icon: Icons.calendar_today_outlined,
      iconColor: AppColors.actionCalendar,
    ),
    MockCareItem(
      title: 'Control veterinario',
      subtitle: 'Viernes, 3 de mayo a las 10:30',
      detail: 'Clínica VetPet',
      status: 'Pendiente',
      icon: Icons.calendar_month_outlined,
      iconColor: AppColors.actionCalendar,
    ),
    MockCareItem(
      title: 'Paseo grupal',
      subtitle: 'Sábado, 5 de mayo a las 09:00',
      detail: 'Parque Bicentenario',
      status: 'Confirmado',
      icon: Icons.directions_walk_outlined,
      iconColor: AppColors.actionCalendar,
    ),
  ];

  static const List<MockCareItem> vaccineItems = [
    MockCareItem(
      title: 'Vacuna Rabia',
      subtitle: 'Martes, 30 de abril',
      detail: 'Dosis anual — Clínica VetPet',
      status: 'Próxima',
      icon: Icons.vaccines_outlined,
      iconColor: AppColors.actionVaccines,
    ),
    MockCareItem(
      title: 'Vacuna Octuple',
      subtitle: 'Aplicada el 12 de enero 2026',
      detail: 'Refuerzo completado',
      status: 'Al día',
      icon: Icons.vaccines_outlined,
      iconColor: AppColors.actionVaccines,
    ),
    MockCareItem(
      title: 'Desparasitación interna',
      subtitle: 'Programada para el 15 de mayo',
      detail: 'Tableta mensual',
      status: 'Pendiente',
      icon: Icons.medical_services_outlined,
      iconColor: AppColors.actionVaccines,
    ),
  ];

  static const List<MockCareItem> medicineItems = [
    MockCareItem(
      title: 'Control Parásitos',
      subtitle: 'Viernes, 10 de mayo — 08:00',
      detail: '1 tableta con el desayuno',
      status: 'Activo',
      icon: Icons.medication_outlined,
      iconColor: AppColors.actionMedicines,
    ),
    MockCareItem(
      title: 'Omega 3',
      subtitle: 'Diario — mañana y noche',
      detail: '5 ml en la comida',
      status: 'Activo',
      icon: Icons.medication_liquid_outlined,
      iconColor: AppColors.actionMedicines,
    ),
    MockCareItem(
      title: 'Antiinflamatorio',
      subtitle: 'Finalizado el 2 de abril',
      detail: 'Tratamiento post cirugía',
      status: 'Completado',
      icon: Icons.healing_outlined,
      iconColor: AppColors.actionMedicines,
    ),
  ];

  static const List<MockCareItem> serviceItems = [
    MockCareItem(
      title: 'Esterilización Oliver',
      subtitle: 'Clínica VetPet',
      detail: 'Cirugía programada — consultar horario',
      status: 'Referencia',
      icon: Icons.home_repair_service_outlined,
      iconColor: AppColors.actionServices,
    ),
    MockCareItem(
      title: 'Peluquería completa',
      subtitle: 'Happy Paws — Última visita: 10 mar',
      detail: 'Baño, corte y uñas',
      status: 'Realizado',
      icon: Icons.content_cut_outlined,
      iconColor: AppColors.actionServices,
    ),
    MockCareItem(
      title: 'Hotel canino',
      subtitle: 'Reserva: 20–22 de mayo',
      detail: 'Pet Lodge Santiago',
      status: 'Reservado',
      icon: Icons.house_outlined,
      iconColor: AppColors.actionServices,
    ),
  ];

  static const List<MockCareItem> historyItems = [
    MockCareItem(
      title: 'Vacuna Octuple',
      subtitle: '12 de enero 2026',
      detail: 'Clínica VetPet — Dr. Soto',
      icon: Icons.vaccines_outlined,
      iconColor: AppColors.actionVaccines,
    ),
    MockCareItem(
      title: 'Baño y arreglo',
      subtitle: '10 de marzo 2026',
      detail: 'Happy Paws',
      icon: Icons.content_cut_outlined,
      iconColor: AppColors.actionServices,
    ),
    MockCareItem(
      title: 'Consulta general',
      subtitle: '5 de febrero 2026',
      detail: 'Revisión anual — sin novedades',
      icon: Icons.medical_information_outlined,
      iconColor: AppColors.primary,
    ),
  ];

  static const List<MockCareItem> petAgendaItems = [
    MockCareItem(
      title: 'Baño',
      subtitle: 'Mañana, martes 25 a las 16:00',
      icon: Icons.calendar_today_outlined,
      iconColor: AppColors.actionCalendar,
    ),
    MockCareItem(
      title: 'Vacuna Rabia',
      subtitle: 'Martes, 30 de abril',
      icon: Icons.vaccines_outlined,
      iconColor: AppColors.actionVaccines,
    ),
    MockCareItem(
      title: 'Control Parásitos',
      subtitle: 'Viernes, 10 de mayo',
      icon: Icons.medication_outlined,
      iconColor: AppColors.actionMedicines,
    ),
    MockCareItem(
      title: 'Esterilización Oliver',
      subtitle: 'Clínica VetPet',
      icon: Icons.pets_outlined,
      iconColor: AppColors.actionServices,
    ),
  ];
}
