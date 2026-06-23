import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _chipController = TextEditingController();

  String _species = 'Perro';

  static const _speciesOptions = ['Perro', 'Gato', 'Otro'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _chipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Agregar mascota',
      subtitle: 'Registra una nueva mascota en tu cuenta',
      icon: Icons.pets_outlined,
      color: AppColors.primary,
      formKey: _formKey,
      submitLabel: 'Guardar mascota',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Nombre',
          controller: _nameController,
          hint: 'Ej: Carolina',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa el nombre' : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Especie',
          value: _species,
          items: _speciesOptions
              .map(
                (species) => DropdownMenuItem(
                  value: species,
                  child: Text(species),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) _species = value;
          },
        ),
        LabeledTextField(
          label: 'Raza',
          controller: _breedController,
          hint: 'Ej: Mestiza',
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Edad',
          controller: _ageController,
          hint: 'Ej: 3 años',
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Peso',
          controller: _weightController,
          hint: 'Ej: 12 kg',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Microchip (opcional)',
          controller: _chipController,
          hint: 'Ej: 985.123.456',
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(
      context,
      'Mascota "${_nameController.text.trim()}" registrada',
    );
    context.pop();
  }
}
