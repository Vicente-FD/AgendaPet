import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:agenda_pet/shared/widgets/photo_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Formulario para registrar un evento significativo / recuerdo.
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'Cumpleaños';

  static const _typeOptions = [
    'Cumpleaños',
    'Primera vez',
    'Adopción',
    'Logro',
    'Otro',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Uint8List? _photo;

  Future<void> _pickDate() async {
    final now = DateTime(2026, 6, 23);
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2015),
      lastDate: now,
    );
    if (picked != null) {
      _dateController.text = formatShortDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Agregar evento',
      subtitle: 'Guarda un recuerdo especial',
      icon: Icons.celebration_outlined,
      color: AppColors.memories,
      formKey: _formKey,
      submitLabel: 'Guardar evento',
      onSubmit: _submit,
      children: [
        PhotoPickerField(
          label: 'Foto (opcional)',
          imageBytes: _photo,
          color: AppColors.memories,
          onChanged: (bytes) => setState(() => _photo = bytes),
        ),
        LabeledTextField(
          label: 'Título',
          controller: _titleController,
          hint: 'Ej: Primer baño',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa un título' : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Tipo de evento',
          value: _type,
          items: _typeOptions
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) {
            if (value != null) _type = value;
          },
        ),
        LabeledTextField(
          label: 'Fecha',
          controller: _dateController,
          hint: 'Selecciona la fecha',
          readOnly: true,
          onTap: _pickDate,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecciona la fecha' : null,
        ),
        LabeledTextField(
          label: 'Nota o recuerdo',
          controller: _noteController,
          hint: 'Cuenta qué hizo especial este momento',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(
      context,
      'Evento "${_titleController.text.trim()}" guardado',
    );
    context.pop();
  }
}
