// Datos de prueba para el calendario de la agenda.
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum CareEventType {
  agenda,
  vaccines,
  medicines,
  services,
}

extension CareEventTypeX on CareEventType {
  Color get color {
    return switch (this) {
      CareEventType.agenda => AppColors.actionCalendar,
      CareEventType.vaccines => AppColors.actionVaccines,
      CareEventType.medicines => AppColors.actionMedicines,
      CareEventType.services => AppColors.actionServices,
    };
  }

  String get label {
    return switch (this) {
      CareEventType.agenda => 'Agenda',
      CareEventType.vaccines => 'Vacunas',
      CareEventType.medicines => 'Medicinas',
      CareEventType.services => 'Servicios',
    };
  }
}

class MockCalendarEvent {
  MockCalendarEvent({
    required this.date,
    required this.title,
    required this.type,
    required this.isCompleted,
    this.subtitle,
  });

  final DateTime date;
  final String title;
  final CareEventType type;
  final bool isCompleted;
  final String? subtitle;
}

abstract final class AgendaCalendarMockData {
  static final DateTime initialMonth = DateTime(2026, 6);

  static final List<MockCalendarEvent> events = [
    MockCalendarEvent(
      date: DateTime(2026, 3, 10),
      title: 'Peluquería completa',
      subtitle: 'Happy Paws',
      type: CareEventType.services,
      isCompleted: true,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 4, 2),
      title: 'Antiinflamatorio',
      subtitle: 'Tratamiento finalizado',
      type: CareEventType.medicines,
      isCompleted: true,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 4, 30),
      title: 'Vacuna Rabia',
      subtitle: 'Clínica VetPet',
      type: CareEventType.vaccines,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 5, 3),
      title: 'Control veterinario',
      subtitle: '10:30 — Clínica VetPet',
      type: CareEventType.agenda,
      isCompleted: true,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 5, 5),
      title: 'Paseo grupal',
      subtitle: 'Parque Bicentenario',
      type: CareEventType.agenda,
      isCompleted: true,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 5, 10),
      title: 'Control Parásitos',
      subtitle: '08:00 — 1 tableta',
      type: CareEventType.medicines,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 5, 15),
      title: 'Desparasitación interna',
      subtitle: 'Tableta mensual',
      type: CareEventType.vaccines,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 5, 20),
      title: 'Hotel canino',
      subtitle: 'Inicio — Pet Lodge Santiago',
      type: CareEventType.services,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 5, 22),
      title: 'Hotel canino',
      subtitle: 'Fin — Pet Lodge Santiago',
      type: CareEventType.services,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 6, 5),
      title: 'Baño',
      subtitle: '16:00 — Happy Paws',
      type: CareEventType.agenda,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 6, 11),
      title: 'Omega 3',
      subtitle: 'Dosis diaria',
      type: CareEventType.medicines,
      isCompleted: false,
    ),
    MockCalendarEvent(
      date: DateTime(2026, 6, 25),
      title: 'Baño programado',
      subtitle: '16:00 — Happy Paws',
      type: CareEventType.agenda,
      isCompleted: false,
    ),
  ];

  static List<MockCalendarEvent> eventsForDay(DateTime day) {
    return events.where((event) => _isSameDay(event.date, day)).toList();
  }

  static List<MockCalendarEvent> eventsForMonth(DateTime month) {
    return events
        .where(
          (event) =>
              event.date.year == month.year && event.date.month == month.month,
        )
        .toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
