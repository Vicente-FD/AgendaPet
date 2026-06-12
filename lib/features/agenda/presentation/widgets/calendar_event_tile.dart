import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({super.key, required this.event});

  final MockCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final color = event.type.color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: event.isCompleted ? color.withValues(alpha: 0.4) : color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      _StatusBadge(
                        label: event.isCompleted ? 'Realizado' : 'Pendiente',
                        color: color,
                        completed: event.isCompleted,
                      ),
                    ],
                  ),
                  if (event.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    event.type.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.completed,
  });

  final String label;
  final Color color;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: completed ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
