import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/agenda/presentation/widgets/agenda_calendar.dart';
import 'package:agenda_pet/features/agenda/presentation/widgets/calendar_event_tile.dart';
import 'package:agenda_pet/features/agenda/presentation/widgets/calendar_legend.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedMonth = AgendaCalendarMockData.initialMonth;
    _selectedDay = DateTime(2026, 6, 11);
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = AgendaCalendarMockData.eventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Calendario de Carolina',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Los colores indican el tipo de acción; los tonos suaves son eventos ya realizados.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          AgendaCalendar(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            onMonthChanged: (month) => setState(() => _focusedMonth = month),
            onDaySelected: (day) => setState(() {
              _selectedDay = day;
              _focusedMonth = DateTime(day.year, day.month);
            }),
          ),
          const SizedBox(height: 12),
          const CalendarLegend(),
          const SizedBox(height: 20),
          Text(
            _sectionTitle(_selectedDay),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (dayEvents.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Sin eventos para este día.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            )
          else
            ...dayEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CalendarEventTile(event: event),
              ),
            ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Agregar cita',
            icon: Icons.add,
            onPressed: () => context.goAddAppointment(),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(DateTime day) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return 'Eventos del ${day.day} de ${months[day.month - 1]}';
  }
}
