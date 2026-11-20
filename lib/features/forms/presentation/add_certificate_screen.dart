import 'dart:typed_data';

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:agenda_pet/shared/widgets/labeled_dropdown_field.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:agenda_pet/shared/widgets/photo_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Formulario para registrar un certificado o documento de la mascota.
/// Permite escanear/fotografiar el documento o adjuntarlo desde la galería.
class AddCertificateScreen extends StatefulWidget {
  const AddCertificateScreen({super.key});

  @override
  State<AddCertificateScreen> createState() => _AddCertificateScreenState();
}

class _AddCertificateScreenState extends State<AddCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _issuerController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'Vacuna';
  Uint8List? _scan;
  String? _attachedFileName;

  static const _types = [
    'Vacuna',
    'Carnet de vacunas',
    'Perro de compañía',
    'Microchip',
    'Pedigrí',
    'Otro',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;
    setState(() => _dateController.text = formatShortDate(picked));
  }

  Future<void> _attachMockPdf() async {
    // Fase 1 UI: simula adjuntar un PDF sin backend ni file_picker.
    setState(() {
      _attachedFileName =
          'documento_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _scan = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Archivo PDF adjunto (vista previa)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_scan == null && _attachedFileName == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Escanea o adjunta el documento'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    showFormSavedSnackBar(
      context,
      'Certificado "${_titleController.text.trim()}" guardado',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AddFormScaffold(
      title: 'Agregar certificado',
      subtitle: 'Escanea o adjunta un documento de Carolina',
      icon: Icons.document_scanner_outlined,
      color: AppColors.certificates,
      formKey: _formKey,
      submitLabel: 'Guardar certificado',
      onSubmit: _submit,
      children: [
        LabeledDropdownField<String>(
          label: 'Tipo de documento',
          value: _type,
          items: _types
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) {
            if (value != null) _type = value;
          },
        ),
        LabeledTextField(
          label: 'Nombre',
          controller: _titleController,
          hint: 'Ej: Certificado vacuna antirrábica',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa un nombre'
              : null,
          textInputAction: TextInputAction.next,
        ),
        LabeledTextField(
          label: 'Fecha de emisión',
          controller: _dateController,
          hint: 'Selecciona una fecha',
          readOnly: true,
          onTap: _pickDate,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecciona una fecha' : null,
        ),
        LabeledTextField(
          label: 'Emitido por',
          controller: _issuerController,
          hint: 'Ej: Clínica VetPet / Municipalidad',
          textInputAction: TextInputAction.next,
        ),
        PhotoPickerField(
          label: 'Escanear o fotografiar',
          imageBytes: _scan,
          color: AppColors.certificates,
          emptyHint: 'Toca para escanear con la cámara o elegir imagen',
          emptyIcon: Icons.document_scanner_outlined,
          onChanged: (bytes) => setState(() {
            _scan = bytes;
            if (bytes != null) _attachedFileName = null;
          }),
        ),
        OutlinedButton.icon(
          onPressed: _attachMockPdf,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(
            _attachedFileName == null
                ? 'Adjuntar PDF (opcional)'
                : 'PDF: $_attachedFileName',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.certificates,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        LabeledTextField(
          label: 'Notas (opcional)',
          controller: _notesController,
          hint: 'Vigencia, número de folio, observaciones',
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
