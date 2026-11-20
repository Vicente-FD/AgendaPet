import 'package:agenda_pet/core/state/feeding_store.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/feeding/data/feeding_dto.dart';
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
  DateTime? _openedAt;
  bool _saving = false;

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
      _openedAt = picked;
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

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final mascota = PetsStore.instance.selected;
    if (mascota == null) {
      _aviso('Primero agrega una mascota para registrar su alimento.');
      return;
    }

    setState(() => _saving = true);
    try {
      await FeedingStore.instance.add(
        mascota.id,
        FeedingDto(
          id: '',
          foodName: _foodController.text.trim(),
          brand: _brandController.text.trim(),
          kind: FeedingDto.tipoApi(_kind),
          bagSizeKg: double.tryParse(
            _bagController.text.trim().replaceAll(',', '.'),
          ),
          dailyGrams: int.tryParse(_rationController.text.trim()),
          openedAt: _openedAt,
        ),
      );
      if (!mounted) return;
      showFormSavedSnackBar(context, 'Alimento registrado');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _aviso('No se pudo guardar: ${mensajeDeError(e)}');
    }
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
      );
  }
}
