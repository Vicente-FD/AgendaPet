import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:go_router/go_router.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _detailsController = TextEditingController();
  final _dateController = TextEditingController();

  String _serviceType = 'Peluquería';

  static const _serviceTypes = [
    'Peluquería',
    'Clínica',
    'Hospedaje',
    'Paseo',
    'Otro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Agregar servicio',
      subtitle: 'Registra peluquería, clínica u otro servicio',
      icon: Icons.home_repair_service_outlined,
      color: AppColors.actionServices,
      formKey: _formKey,
      submitLabel: 'Guardar servicio',
      onSubmit: _submit,
      children: [
        LabeledTextField(
          label: 'Nombre del servicio',
          controller: _nameController,
          hint: 'Ej: Peluquería completa',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa el nombre' : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Tipo de servicio',
          value: _serviceType,
          items: _serviceTypes
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) _serviceType = value;
          },
        ),
        LabeledTextField(
          label: 'Proveedor',
          controller: _providerController,
          hint: 'Ej: Happy Paws',
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Ingresa el proveedor' : null,
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
          label: 'Detalles (opcional)',
          controller: _detailsController,
          hint: 'Baño, corte, reserva, etc.',
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
      'Servicio "${_nameController.text.trim()}" guardado',
    );
    context.pop();
  }
}
