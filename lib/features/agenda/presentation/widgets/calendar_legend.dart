import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leyenda',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: CareEventType.values.map((type) {
                return _LegendItem(
                  color: type.color,
                  label: type.label,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const _LegendDot(
                  color: AppColors.actionCalendar,
                  completed: false,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pendiente',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(width: 16),
                const _LegendDot(
                  color: AppColors.actionCalendar,
                  completed: true,
                ),
                const SizedBox(width: 6),
                Text(
                  'Realizado',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendDot(color: color, completed: false),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.completed});

  final Color color;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: completed ? color.withValues(alpha: 0.35) : color,
        shape: BoxShape.circle,
        border: completed ? Border.all(color: color, width: 1) : null,
      ),
    );
  }
}
