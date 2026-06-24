import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:agenda_pet/shared/widgets/photo_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Formulario para añadir una nueva foto/etapa al historial de crecimiento.
class AddGrowthScreen extends StatefulWidget {
  const AddGrowthScreen({super.key});

  @override
  State<AddGrowthScreen> createState() => _AddGrowthScreenState();
}

class _AddGrowthScreenState extends State<AddGrowthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _noteController = TextEditingController();

  Uint8List? _photo;

  @override
  void dispose() {
    _dateController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

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
      title: 'Agregar foto',
      subtitle: 'Registra una nueva etapa del crecimiento',
      icon: Icons.add_a_photo_outlined,
      color: AppColors.growth,
      formKey: _formKey,
      submitLabel: 'Guardar etapa',
      onSubmit: _submit,
      children: [
        PhotoPickerField(
          label: 'Foto de la mascota',
          imageBytes: _photo,
          color: AppColors.growth,
          onChanged: (bytes) => setState(() => _photo = bytes),
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
          label: 'Edad aproximada',
          controller: _ageController,
          hint: 'Ej: 8 meses',
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Peso',
          controller: _weightController,
          hint: 'Ej: 4 kg',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Tamaño / altura',
          controller: _heightController,
          hint: 'Ej: 30 cm',
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Nota o recuerdo',
          controller: _noteController,
          hint: 'Ej: Recién llegada a casa',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(context, 'Etapa de crecimiento guardada');
    context.pop();
  }
}
