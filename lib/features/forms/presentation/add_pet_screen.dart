import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/features/pets/data/pet_dto.dart';
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
  final _birthController = TextEditingController();
  final _weightController = TextEditingController();

  String _species = 'Perro';
  DateTime? _birthDate;
  bool _saving = false;

  static const _speciesOptions = ['Perro', 'Gato', 'Otro'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _birthController.dispose();
    _weightController.dispose();
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
      submitLabel: _saving ? 'Guardando…' : 'Guardar mascota',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Nombre',
          controller: _nameController,
          hint: 'Ej: Carolina',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa el nombre'
              : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Especie',
          value: _species,
          items: _speciesOptions
              .map(
                (species) =>
                    DropdownMenuItem(value: species, child: Text(species)),
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
          label: 'Fecha de nacimiento (opcional)',
          controller: _birthController,
          hint: 'Selecciona una fecha',
          readOnly: true,
          onTap: _pickBirthDate,
          suffixIcon: const Icon(Icons.cake_outlined),
        ),
        LabeledTextField(
          label: 'Peso en kilos (opcional)',
          controller: _weightController,
          hint: 'Ej: 12.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final peso = double.tryParse(value.trim().replaceAll(',', '.'));
            if (peso == null || peso <= 0) return 'Ingresa un peso válido';
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _pickBirthDate() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(hoy.year - 1, hoy.month, hoy.day),
      firstDate: DateTime(hoy.year - 30),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _birthController.text = formatShortDate(picked);
    });
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final nombre = _nameController.text.trim();
    final peso = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    try {
      await PetsStore.instance.add(
        PetDto(
          id: '',
          name: nombre,
          species: _species,
          breed: _breedController.text.trim(),
          birthDate: _birthDate,
          weightKg: peso,
        ),
      );
      if (!mounted) return;
      showFormSavedSnackBar(context, 'Mascota "$nombre" registrada');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar: ${mensajeDeError(e)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}
