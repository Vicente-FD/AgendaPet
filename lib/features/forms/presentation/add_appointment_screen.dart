import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart' as care;
import 'package:agenda_pet/features/care/data/care_form.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:agenda_pet/core/utils/date_format.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  CareEventType _eventType = CareEventType.agenda;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Agregar cita',
      subtitle: 'Programa un evento en la agenda de Carolina',
      icon: Icons.calendar_month_outlined,
      color: AppColors.actionCalendar,
      formKey: _formKey,
      submitLabel: 'Guardar cita',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Título',
          controller: _titleController,
          hint: 'Ej: Control veterinario',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa un título'
              : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<CareEventType>(
          label: 'Tipo de evento',
          value: _eventType,
          items: CareEventType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) _eventType = value;
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
          label: 'Lugar',
          controller: _locationController,
          hint: 'Ej: Clínica VetPet',
          textInputAction: TextInputAction.next,
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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = picked;
      _dateController.text = formatShortDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedTime = picked;
      _timeController.text = picked.format(context);
    });
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final titulo = _titleController.text.trim();
    final fecha = _selectedDate ?? DateTime.now();
    final hora = _selectedTime ?? TimeOfDay.now();

    setState(() => _saving = true);
    final guardado = await guardarCuidado(
      context,
      type: care.CareType.appointment,
      name: titulo,
      date: DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      ),
      notes: notasCompuestas({
        'Tipo': _eventType.label,
        'Lugar': _locationController.text,
        'Notas': _notesController.text,
      }),
      mensajeOk: 'Cita "$titulo" guardada',
    );
    if (!guardado && mounted) setState(() => _saving = false);
  }
}
