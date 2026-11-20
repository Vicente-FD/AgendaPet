import 'package:agenda_pet/core/mocks/care_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:flutter/material.dart';

/// Tipos de registro de cuidado, tal como los nombra la API.
enum CareType {
  vaccine('VACCINE', 'Vacuna', Icons.vaccines_outlined, AppColors.actionVaccines),
  medicine('MEDICINE', 'Medicina', Icons.medication_outlined,
      AppColors.actionMedicines),
  service('SERVICE', 'Servicio', Icons.build_outlined, AppColors.actionServices),
  appointment('APPOINTMENT', 'Cita', Icons.event_outlined,
      AppColors.actionCalendar);

  const CareType(this.api, this.label, this.icon, this.color);

  final String api;
  final String label;
  final IconData icon;
  final Color color;

  static CareType fromApi(String value) =>
      CareType.values.firstWhere((t) => t.api == value,
          orElse: () => CareType.appointment);
}

/// Registro de cuidado: vacuna, medicina, servicio o cita.
class CareDto {
  const CareDto({
    required this.id,
    required this.type,
    required this.name,
    required this.date,
    this.nextDueDate,
    this.notes,
  });

  final String id;
  final CareType type;
  final String name;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? notes;

  factory CareDto.fromJson(Map<String, dynamic> json) => CareDto(
        id: json['id'] as String,
        type: CareType.fromApi(json['type'] as String),
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String).toLocal(),
        nextDueDate: json['nextDueDate'] == null
            ? null
            : DateTime.parse(json['nextDueDate'] as String).toLocal(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type.api,
        'name': name,
        'date': date.toUtc().toIso8601String(),
        if (nextDueDate != null)
          'nextDueDate': nextDueDate!.toUtc().toIso8601String(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  /// ¿El próximo control ya se pasó de fecha?
  bool get vencido =>
      nextDueDate != null && nextDueDate!.isBefore(DateTime.now());

  /// Adapta el registro a la tarjeta que ya usan las pantallas de cuidado.
  MockCareItem toItem() {
    final proximo = nextDueDate;
    return MockCareItem(
      title: name,
      subtitle: 'Registrado el ${formatShortDate(date)}',
      detail: proximo == null
          ? notes
          : 'Próximo: ${formatShortDate(proximo)}'
              '${notes == null || notes!.isEmpty ? '' : ' · $notes'}',
      status: proximo == null ? null : (vencido ? 'Vencido' : 'Al día'),
      icon: type.icon,
      iconColor: type.color,
    );
  }
}
