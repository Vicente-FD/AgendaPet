import 'package:agenda_pet/core/state/care_store.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/features/care/data/care_dto.dart';
import 'package:agenda_pet/shared/widgets/category_screen_layout.dart';
import 'package:flutter/material.dart';

/// Pantalla común de vacunas, medicinas y servicios: cambia el tipo y los
/// textos, pero todas leen los registros reales de la mascota seleccionada.
class CareCategoryScreen extends StatefulWidget {
  const CareCategoryScreen({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.addButtonLabel,
    required this.onAddPressed,
    this.emptyMessage,
  });

  final CareType type;
  final String title;
  final String subtitle;
  final String addButtonLabel;
  final VoidCallback onAddPressed;
  final String? emptyMessage;

  @override
  State<CareCategoryScreen> createState() => _CareCategoryScreenState();
}

class _CareCategoryScreenState extends State<CareCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar({bool force = false}) async {
    await PetsStore.instance.load(force: force);
    await CareStore.instance.loadForSelected(force: force);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([PetsStore.instance, CareStore.instance]),
      builder: (context, _) {
        final store = CareStore.instance;
        final mascota = PetsStore.instance.selected;
        final registros = store.byType(widget.type);

        return CategoryScreenLayout(
          title: widget.title,
          subtitle: mascota == null
              ? widget.subtitle
              : '${widget.subtitle} · ${mascota.name}',
          icon: widget.type.icon,
          color: widget.type.color,
          items: [for (final r in registros) r.toItem()],
          loading: store.loading && registros.isEmpty,
          statusMessage: store.error ??
              (mascota == null
                  ? 'Agrega una mascota para registrar su cuidado.'
                  : widget.emptyMessage),
          onRefresh: () => _cargar(force: true),
          addButtonLabel: widget.addButtonLabel,
          onAddPressed: widget.onAddPressed,
        );
      },
    );
  }
}
