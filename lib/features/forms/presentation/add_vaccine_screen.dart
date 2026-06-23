import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:go_router/go_router.dart';

class AddVaccineScreen extends StatefulWidget {
  const AddVaccineScreen({super.key});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clinicController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _clinicController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Registrar vacuna',
      subtitle: 'Añade una vacuna o desparasitación al historial',
      icon: Icons.vaccines_outlined,
      color: AppColors.actionVaccines,
      formKey: _formKey,
      submitLabel: 'Guardar vacuna',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Nombre',
          controller: _nameController,
          hint: 'Ej: Vacuna Rabia',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa el nombre' : null,
          textInputAction: TextInputAction.next,
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
          label: 'Clínica o veterinario',
          controller: _clinicController,
          hint: 'Ej: Clínica VetPet',
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Notas (opcional)',
          controller: _notesController,
          hint: 'Dosis, refuerzo, observaciones',
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _dateController.text = formatShortDate(picked);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(
      context,
      'Vacuna "${_nameController.text.trim()}" registrada',
    );
    context.pop();
  }
}
