import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _notesController = TextEditingController();

  String _frequency = 'Diario';

  static const _frequencies = ['Diario', 'Semanal', 'Mensual', 'Según necesidad'];

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Agregar medicina',
      subtitle: 'Registra un tratamiento o medicación activa',
      icon: Icons.medication_outlined,
      color: AppColors.actionMedicines,
      formKey: _formKey,
      submitLabel: 'Guardar medicina',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Nombre',
          controller: _nameController,
          hint: 'Ej: Omega 3',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa el nombre' : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Frecuencia',
          value: _frequency,
          items: _frequencies
              .map(
                (freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) _frequency = value;
          },
        ),
        LabeledTextField(
          label: 'Dosis',
          controller: _doseController,
          hint: 'Ej: 1 tableta con el desayuno',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa la dosis' : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Notas (opcional)',
          controller: _notesController,
          hint: 'Duración del tratamiento, indicaciones',
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(
      context,
      'Medicina "${_nameController.text.trim()}" guardada',
    );
    context.pop();
  }
}
