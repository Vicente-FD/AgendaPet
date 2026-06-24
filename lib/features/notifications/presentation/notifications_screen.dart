import 'package:agenda_pet/core/mocks/notifications_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Notificaciones agrupadas por tipo (Crecimiento, Recuerdos, Salud, Día a día).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Todas marcadas como leídas'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
            },
            child: const Text('Leer todo'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final category in NotificationCategory.values)
            ..._buildCategorySection(context, category),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySection(
    BuildContext context,
    NotificationCategory category,
  ) {
    final items = NotificationsMockData.notifications
        .where((n) => n.category == category)
        .toList();
    if (items.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          children: [
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                category.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: category.color,
                    ),
              ),
            ),
          ],
        ),
      ),
      ...items.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _NotificationTile(notification: item),
        ),
      ),
      const SizedBox(height: 12),
    ];
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final color = notification.category.color;
    return Card(
      color: notification.isRead
          ? context.surfaceMuted
          : color.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notification.category.icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          fontWeight: notification.isRead
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
