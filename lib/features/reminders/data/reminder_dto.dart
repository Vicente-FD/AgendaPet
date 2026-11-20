import 'package:agenda_pet/core/mocks/home_mock_data.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:flutter/material.dart';

/// Recordatorio tal como lo entrega la API (`GET /pets/:petId/reminders`).
class ReminderDto {
  const ReminderDto({
    required this.id,
    required this.title,
    required this.dueAt,
    this.type,
    this.done = false,
  });

  final String id;
  final String title;
  final DateTime dueAt;
  final String? type;
  final bool done;

  factory ReminderDto.fromJson(Map<String, dynamic> json) => ReminderDto(
        id: json['id'] as String,
        title: json['title'] as String,
        dueAt: DateTime.parse(json['dueAt'] as String).toLocal(),
        type: json['type'] as String?,
        done: (json['done'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'dueAt': dueAt.toUtc().toIso8601String(),
        if (type != null && type!.isNotEmpty) 'type': type,
        'done': done,
      };

  /// Texto de fecha y hora para la tarjeta ("Mañana a las 16:00").
  String get whenLabel {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final dia = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final hora = '${dueAt.hour.toString().padLeft(2, '0')}:'
        '${dueAt.minute.toString().padLeft(2, '0')}';
    final dias = dia.difference(hoy).inDays;
    if (dias == 0) return 'Hoy a las $hora';
    if (dias == 1) return 'Mañana a las $hora';
    return '${formatShortDate(dueAt)} a las $hora';
  }

  static const _icons = {
    'Vacuna': Icons.vaccines_outlined,
    'Medicina': Icons.medication_outlined,
    'Servicio': Icons.build_outlined,
    'Agenda': Icons.calendar_today_outlined,
  };
  static const _colors = {
    'Vacuna': Color(0xFF43A047),
    'Medicina': Color(0xFF8E24AA),
    'Servicio': Color(0xFFF4511E),
    'Agenda': Color(0xFF1E88E5),
  };

  /// Adapta el recordatorio al modelo que consume `ReminderCard`.
  MockReminder toCard() {
    final key = type ?? 'Agenda';
    return MockReminder(
      title: title,
      subtitle: whenLabel,
      icon: _icons[key] ?? Icons.notifications_active_outlined,
      iconColor: _colors[key] ?? const Color(0xFF1E88E5),
      showAction: !done,
    );
  }
}
