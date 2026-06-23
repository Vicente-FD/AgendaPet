import 'package:agenda_pet/core/mocks/agenda_calendar_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
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
    return AddFormScaffold(
      title: 'Añadir recordatorio',
      subtitle: 'Crea un recordatorio para el cuidado de Carolina',
      icon: Icons.notifications_active_outlined,
      color: AppColors.primary,
      formKey: _formKey,
      submitLabel: 'Guardar recordatorio',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Título',
          controller: _titleController,
          hint: 'Ej: Baño',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa un título' : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<CareEventType>(
          label: 'Categoría',
          value: _category,
          items: CareEventType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                ),
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _dateController.text = formatShortDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _timeController.text = picked.format(context);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(
      context,
      'Recordatorio "${_titleController.text.trim()}" guardado',
    );
    context.pop();
  }
}
