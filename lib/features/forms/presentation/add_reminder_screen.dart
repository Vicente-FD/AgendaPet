import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/notifications/local_notifications.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/state/reminders_store.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/features/reminders/data/reminder_dto.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  CareEventType _category = CareEventType.agenda;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  /// Tipo que guarda la API para cada categoría de la UI.
  static const _tipoApi = {
    CareEventType.agenda: 'Agenda',
    CareEventType.vaccines: 'Vacuna',
    CareEventType.medicines: 'Medicina',
    CareEventType.services: 'Servicio',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PetsStore.instance.load();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascota = PetsStore.instance.selected;

    return AddFormScaffold(
      title: 'Añadir recordatorio',
      subtitle: mascota == null
          ? 'Crea un recordatorio para el cuidado de tu mascota'
          : 'Crea un recordatorio para el cuidado de ${mascota.name}',
      icon: Icons.notifications_active_outlined,
      color: AppColors.primary,
      formKey: _formKey,
      submitLabel: _saving ? 'Guardando…' : 'Guardar recordatorio',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Título',
          controller: _titleController,
          hint: 'Ej: Baño',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa un título'
              : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<CareEventType>(
          label: 'Categoría',
          value: _category,
          items: CareEventType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) _category = value;
          },
        ),
        LabeledTextField(
          label: 'Fecha',
          controller: _dateController,
          hint: 'Selecciona una fecha',
          readOnly: true,
          onTap: _pickDate,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecciona una fecha' : null,
        ),
        LabeledTextField(
          label: 'Hora',
          controller: _timeController,
          hint: 'Selecciona una hora',
          readOnly: true,
          onTap: _pickTime,
          suffixIcon: const Icon(Icons.access_time_outlined),
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecciona una hora' : null,
        ),
        LabeledTextField(
          label: 'Notas (opcional)',
          controller: _notesController,
          hint: 'Detalles adicionales',
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateController.text = formatShortDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeController.text = picked.format(context);
    });
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final mascota = PetsStore.instance.selected;
    if (mascota == null) {
      _mostrarError('Primero agrega una mascota para asociar el recordatorio.');
      return;
    }

    final fecha = _date!;
    final hora = _time!;
    final titulo = _titleController.text.trim();

    setState(() => _saving = true);
    try {
      // La primera vez pide permiso para avisar; si lo niegan, el recordatorio
      // se guarda igual, solo que sin notificación.
      await LocalNotifications.pedirPermiso();
      await RemindersStore.instance.add(
        mascota.id,
        ReminderDto(
          id: '',
          title: titulo,
          type: _tipoApi[_category],
          dueAt: DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          ),
        ),
      );
      if (!mounted) return;
      showFormSavedSnackBar(context, 'Recordatorio "$titulo" guardado');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _mostrarError('No se pudo guardar: ${mensajeDeError(e)}');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
      );
  }
}
