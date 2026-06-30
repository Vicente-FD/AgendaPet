import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Formulario para registrar el alimento de la mascota. Mock (frontend):
/// guarda y vuelve, sin persistencia real.
class AddFeedingScreen extends StatefulWidget {
  const AddFeedingScreen({super.key});

  @override
  State<AddFeedingScreen> createState() => _AddFeedingScreenState();
}

class _AddFeedingScreenState extends State<AddFeedingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodController = TextEditingController();
  final _brandController = TextEditingController();
  final _bagController = TextEditingController();
  final _rationController = TextEditingController();
  final _openedController = TextEditingController();

  String _kind = 'Seco';

  @override
  void dispose() {
    _foodController.dispose();
    _brandController.dispose();
    _bagController.dispose();
    _rationController.dispose();
    _openedController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime(2026, 6, 28);
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: now,
    );
    if (picked != null) {
      _openedController.text = formatShortDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Registrar alimento',
      subtitle: 'Guarda la marca y la ración para calcular la compra',
      icon: Icons.restaurant_outlined,
      color: AppColors.feeding,
      formKey: _formKey,
      submitLabel: 'Guardar alimento',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Nombre del alimento',
          controller: _foodController,
          hint: 'Ej: Adulto Razas Medianas',
          textInputAction: TextInputAction.next,
          validator: (value) =>
              value == null || value.isEmpty ? 'Ingresa el alimento' : null,
        ),
        LabeledTextField(
          label: 'Marca',
          controller: _brandController,
          hint: 'Ej: ProPlan',
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Tipo',
          value: _kind,
          items: const [
            DropdownMenuItem(value: 'Seco', child: Text('Seco')),
            DropdownMenuItem(value: 'Húmedo', child: Text('Húmedo')),
            DropdownMenuItem(value: 'Mixto', child: Text('Mixto')),
          ],
          onChanged: (value) => setState(() => _kind = value ?? 'Seco'),
        ),
        LabeledTextField(
          label: 'Tamaño del saco (kg)',
          controller: _bagController,
          hint: 'Ej: 7.5',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Ración diaria (g)',
          controller: _rationController,
          hint: 'Ej: 220',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Fecha de apertura',
          controller: _openedController,
          hint: 'Selecciona la fecha',
          readOnly: true,
          onTap: _pickDate,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showFormSavedSnackBar(context, 'Alimento registrado');
    context.pop();
  }
}
