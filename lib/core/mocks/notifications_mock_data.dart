import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum NotificationCategory { crecimiento, recuerdos, salud, engagement }

extension NotificationCategoryX on NotificationCategory {
  String get label => switch (this) {
        NotificationCategory.crecimiento => 'Crecimiento',
        NotificationCategory.recuerdos => 'Recuerdos',
        NotificationCategory.salud => 'Salud',
        NotificationCategory.engagement => 'Día a día',
      };

  Color get color => switch (this) {
        NotificationCategory.crecimiento => AppColors.growth,
        NotificationCategory.recuerdos => AppColors.memories,
        NotificationCategory.salud => AppColors.actionMedicines,
        NotificationCategory.engagement => AppColors.primary,
      };

  IconData get icon => switch (this) {
        NotificationCategory.crecimiento => Icons.straighten_outlined,
        NotificationCategory.recuerdos => Icons.favorite_outline,
        NotificationCategory.salud => Icons.health_and_safety_outlined,
        NotificationCategory.engagement => Icons.pets_outlined,
      };
}

/// Notificación que incentiva al usuario a abrir la app.
class AppNotification {
  const AppNotification({
    required this.message,
    required this.timeLabel,
    required this.category,
    this.isRead = false,
  });

  final String message;
  final String timeLabel;
  final NotificationCategory category;
  final bool isRead;
}

abstract final class NotificationsMockData {
  static const List<AppNotification> notifications = [
    AppNotification(
      message:
          'Hace 30 días que no agregas una foto de Carolina. ¿Quieres ver cuánto ha crecido?',
      timeLabel: 'Hace 2 h',
      category: NotificationCategory.crecimiento,
    ),
    AppNotification(
      message: 'Hoy es un buen día para actualizar el álbum de Carolina.',
      timeLabel: 'Hoy, 09:00',
      category: NotificationCategory.crecimiento,
    ),
    AppNotification(
      message: 'Hace un año registraste el cumpleaños de Carolina 🎂',
      timeLabel: 'Ayer',
      category: NotificationCategory.recuerdos,
    ),
    AppNotification(
      message: '¿Recuerdas este momento? Revive la llegada de Carolina a casa.',
      timeLabel: 'Hace 2 días',
      category: NotificationCategory.recuerdos,
      isRead: true,
    ),
    AppNotification(
      message: 'La vacuna antirrábica vence en 15 días.',
      timeLabel: 'Hace 3 días',
      category: NotificationCategory.salud,
    ),
    AppNotification(
      message: 'Es momento de registrar el peso mensual de Carolina.',
      timeLabel: 'Hace 4 días',
      category: NotificationCategory.salud,
      isRead: true,
    ),
    AppNotification(
      message: 'Registra una nueva aventura de Carolina 📷',
      timeLabel: 'Hace 5 días',
      category: NotificationCategory.engagement,
      isRead: true,
    ),
  ];

  static int get unreadCount =>
      notifications.where((n) => !n.isRead).length;
}
