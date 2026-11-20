import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:agenda_pet/features/care/data/care_form.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:agenda_pet/shared/widgets/photo_picker_field.dart';
import 'package:flutter/material.dart';

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

  String _status = 'Realizada';
  DateTime? _date;
  bool _saving = false;
  Uint8List? _certificateScan;
  String? _certificatePdf;

  static const _statuses = ['Realizada', 'Programada', 'Próxima'];

  bool get _wasAdministered => _status == 'Realizada';

  @override
  void dispose() {
    _nameController.dispose();
    _clinicController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _date = picked;
      _dateController.text = formatShortDate(picked);
    });
  }

  Future<void> _attachMockPdf() async {
    setState(() {
      _certificatePdf =
          'certificado_vacuna_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _certificateScan = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Certificado PDF adjunto (vista previa)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    if (_wasAdministered &&
        _certificateScan == null &&
        _certificatePdf == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Si la vacuna ya se realizó, escanea o adjunta el certificado',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final conCertificado =
        _wasAdministered &&
        (_certificateScan != null || _certificatePdf != null);
    final nombre = _nameController.text.trim();

    setState(() => _saving = true);
    final guardado = await guardarCuidado(
      context,
      type: CareType.vaccine,
      name: nombre,
      date: _date ?? DateTime.now(),
      notes: notasCompuestas({
        'Estado': _status,
        'Clínica': _clinicController.text,
        'Certificado': conCertificado ? 'adjunto' : null,
        'Notas': _notesController.text,
      }),
      mensajeOk:
          'Vacuna "$nombre" registrada${conCertificado ? ' con certificado' : ''}',
    );
    if (!guardado && mounted) setState(() => _saving = false);
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
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa el nombre'
              : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledDropdownField<String>(
          label: 'Estado',
          value: _status,
          items: _statuses
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _status = value);
          },
        ),
        LabeledTextField(
          label: _wasAdministered ? 'Fecha de aplicación' : 'Fecha',
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
        if (_wasAdministered) ...[
          PhotoPickerField(
            label: 'Certificado de la vacuna',
            imageBytes: _certificateScan,
            color: AppColors.actionVaccines,
            emptyHint: 'Escanea o fotografía el certificado / carnet',
            emptyIcon: Icons.document_scanner_outlined,
            onChanged: (bytes) => setState(() {
              _certificateScan = bytes;
              if (bytes != null) _certificatePdf = null;
            }),
          ),
          OutlinedButton.icon(
            onPressed: _attachMockPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              _certificatePdf == null
                  ? 'Adjuntar certificado PDF'
                  : 'PDF: $_certificatePdf',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.actionVaccines,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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
}
