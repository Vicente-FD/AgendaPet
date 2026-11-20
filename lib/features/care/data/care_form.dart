import 'package:agenda_pet/core/state/care_store.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:agenda_pet/shared/widgets/add_form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Guarda un registro de cuidado desde cualquiera de los formularios de alta.
///
/// Se encarga de lo repetido: avisar si no hay mascota, mostrar el error si
/// falla, el mensaje de éxito y volver atrás. Devuelve `true` si guardó.
Future<bool> guardarCuidado(
  BuildContext context, {
  required CareType type,
  required String name,
  required DateTime date,
  required String mensajeOk,
  DateTime? nextDueDate,
  String? notes,
}) async {
  final mascota = PetsStore.instance.selected;
  if (mascota == null) {
    _aviso(context, 'Primero agrega una mascota para registrar su cuidado.');
    return false;
  }

  try {
    await CareStore.instance.add(
      mascota.id,
      CareDto(
        id: '',
        type: type,
        name: name,
        date: date,
        nextDueDate: nextDueDate,
        notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
    if (!context.mounted) return true;
    showFormSavedSnackBar(context, mensajeOk);
    context.pop();
    return true;
  } catch (e) {
    if (context.mounted) {
      _aviso(context, 'No se pudo guardar: ${mensajeDeError(e)}');
    }
    return false;
  }
}

/// Junta los campos que la API no guarda por separado en una sola nota.
String? notasCompuestas(Map<String, String?> campos) {
  final partes = <String>[];
  campos.forEach((etiqueta, valor) {
    if (valor != null && valor.trim().isNotEmpty) {
      partes.add('$etiqueta: ${valor.trim()}');
    }
  });
  return partes.isEmpty ? null : partes.join(' · ');
}

void _aviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
}
