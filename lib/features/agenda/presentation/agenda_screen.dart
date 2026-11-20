import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/care_store.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/state/reminders_store.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart' as care;
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
    final hoy = DateTime.now();
    _focusedMonth = DateTime(hoy.year, hoy.month);
    _selectedDay = DateTime(hoy.year, hoy.month, hoy.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar({bool force = false}) async {
    await PetsStore.instance.load(force: force);
    final mascota = PetsStore.instance.selected;
    if (mascota == null) return;
    await CareStore.instance.loadFor(mascota.id, force: force);
    await RemindersStore.instance.loadFor(mascota.id, force: force);
  }

  /// Junta cuidados y recordatorios en los eventos que pinta el calendario.
  List<MockCalendarEvent> _eventos() {
    const tipos = {
      care.CareType.vaccine: CareEventType.vaccines,
      care.CareType.medicine: CareEventType.medicines,
      care.CareType.service: CareEventType.services,
      care.CareType.appointment: CareEventType.agenda,
    };
    const tiposRecordatorio = {
      'Vacuna': CareEventType.vaccines,
      'Medicina': CareEventType.medicines,
      'Servicio': CareEventType.services,
      'Agenda': CareEventType.agenda,
    };
    final ahora = DateTime.now();

    return [
      for (final r in CareStore.instance.items) ...[
        MockCalendarEvent(
          date: r.date,
          title: r.name,
          type: tipos[r.type] ?? CareEventType.agenda,
          isCompleted: r.date.isBefore(ahora),
          subtitle: r.notes,
        ),
        if (r.nextDueDate != null)
          MockCalendarEvent(
            date: r.nextDueDate!,
            title: 'Próximo: ${r.name}',
            type: tipos[r.type] ?? CareEventType.agenda,
            isCompleted: false,
          ),
      ],
      for (final r in RemindersStore.instance.items)
        MockCalendarEvent(
          date: r.dueAt,
          title: r.title,
          type: tiposRecordatorio[r.type ?? 'Agenda'] ?? CareEventType.agenda,
          isCompleted: r.done,
          subtitle: r.whenLabel,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        PetsStore.instance,
        CareStore.instance,
        RemindersStore.instance,
      ]),
      builder: (context, _) {
        final mascota = PetsStore.instance.selected;
        final eventos = _eventos();
        final dayEvents =
            eventos
                .where(
                  (e) =>
                      e.date.year == _selectedDay.year &&
                      e.date.month == _selectedDay.month &&
                      e.date.day == _selectedDay.day,
                )
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));

        return Scaffold(
          appBar: AppBar(title: const Text('Agenda')),
          body: RefreshIndicator(
            onRefresh: () => _cargar(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  mascota == null
                      ? 'Calendario'
                      : 'Calendario de ${mascota.name}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                  events: eventos,
                  focusedMonth: _focusedMonth,
                  selectedDay: _selectedDay,
                  onMonthChanged: (month) =>
                      setState(() => _focusedMonth = month),
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
          ),
        );
      },
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
