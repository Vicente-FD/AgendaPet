// Calendario mensual con puntos de color por tipo de evento.
import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:flutter/material.dart';

class AgendaCalendar extends StatelessWidget {
  const AgendaCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  static const List<String> _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final monthEvents = AgendaCalendarMockData.eventsForMonth(focusedMonth);
    final days = _buildMonthDays(focusedMonth);
    final monthLabel = _monthYearLabel(focusedMonth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    monthLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _weekdays
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                mainAxisExtent: 52,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                if (day == null) return const SizedBox.shrink();

                final dayEvents = monthEvents
                    .where(
                      (e) =>
                          e.date.year == day.year &&
                          e.date.month == day.month &&
                          e.date.day == day.day,
                    )
                    .toList();
                final isSelected = _isSameDay(day, selectedDay);
                final isToday = _isSameDay(day, DateTime.now());

                return _DayCell(
                  day: day.day,
                  events: dayEvents,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () => onDaySelected(day),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday;

    final cells = <DateTime?>[];
    for (var i = 1; i < startWeekday; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthYearLabel(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final List<MockCalendarEvent> events;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasEvents = events.isNotEmpty;
    final backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.15)
        : hasEvents
            ? context.surfaceMuted
            : Colors.transparent;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : null,
                    ),
              ),
              if (hasEvents) ...[
                const SizedBox(height: 2),
                _EventDots(events: events),
              ] else
                const SizedBox(height: 9),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDots extends StatelessWidget {
  const _EventDots({required this.events});

  final List<MockCalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final uniqueTypes = <CareEventType>[];
    for (final event in events) {
      if (!uniqueTypes.contains(event.type)) {
        uniqueTypes.add(event.type);
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 3,
      children: uniqueTypes.take(4).map((type) {
        final event = events.firstWhere((e) => e.type == type);
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: event.isCompleted
                ? type.color.withValues(alpha: 0.35)
                : type.color,
            shape: BoxShape.circle,
            border: event.isCompleted
                ? Border.all(color: type.color, width: 1)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
