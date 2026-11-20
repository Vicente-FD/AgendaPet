import 'dart:typed_data';

import 'package:agenda_pet/core/mocks/care_mock_data.dart';
import 'package:agenda_pet/core/config/app_config.dart';
import 'package:agenda_pet/core/state/care_store.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/state/reminders_store.dart';
import 'package:agenda_pet/features/pets/data/pet_dto.dart';
import 'package:agenda_pet/features/pets/data/pets_repository.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/care_item_card.dart';
import 'package:agenda_pet/shared/widgets/pet_avatar.dart';
import 'package:agenda_pet/shared/widgets/photo_picker_field.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:agenda_pet/shared/widgets/segmented_tabs.dart';
import 'package:flutter/material.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    await PetsStore.instance.load();
    final mascota = PetsStore.instance.selected;
    if (mascota == null) return;
    await CareStore.instance.loadFor(mascota.id);
    await RemindersStore.instance.loadFor(mascota.id);
  }

  Uint8List? _photo;

  Future<void> _changePhoto() async {
    final bytes = await showPhotoSourceSheet(context);
    if (bytes == null) return;
    setState(() => _photo = bytes);

    final mascota = PetsStore.instance.selected;
    if (mascota == null) return;
    try {
      await PetsStore.instance.subirFoto(mascota.id, bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'La foto se ve en este dispositivo, pero no se pudo '
              'subir: ${mensajeDeError(e)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = CareMockData.petDetail;

    return ListenableBuilder(
      listenable: Listenable.merge([
        PetsStore.instance,
        CareStore.instance,
        RemindersStore.instance,
      ]),
      builder: (context, _) {
        final mascota = PetsStore.instance.selected;
        return Scaffold(
          appBar: AppBar(title: const Text('Perfil')),
          body: mascota == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Agrega una mascota para ver su ficha.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Center(
                      child: PetAvatar(
                        imageBytes: _photo ?? fotosLocales[mascota.id],
                        imageUrl: mascota.avatarUrl,
                        radius: 48,
                        onAddPhoto: _changePhoto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mascota.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${mascota.species}${mascota.breed == null || mascota.breed!.isEmpty ? '' : ' · ${mascota.breed}'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SegmentedTabs(
                      labels: const ['Perfil', 'Agenda', 'Historial'],
                      selectedIndex: _tabIndex,
                      onSelected: (index) => setState(() => _tabIndex = index),
                    ),
                    const SizedBox(height: 20),
                    if (_tabIndex == 0) _ProfileTab(pet: pet, mascota: mascota),
                    if (_tabIndex == 1) const _AgendaTab(),
                    if (_tabIndex == 2) const _HistoryTab(),
                  ],
                ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.pet, required this.mascota});

  final MockPetDetail pet;
  final PetDto mascota;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Raza',
                  value: mascota.breed == null || mascota.breed!.isEmpty
                      ? 'Sin registrar'
                      : mascota.breed!,
                ),
                const Divider(height: 24),
                _InfoRow(label: 'Edad', value: mascota.ageLabel),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Peso',
                  value: mascota.weightKg == null
                      ? 'Sin registrar'
                      : '${mascota.weightKg} kg',
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Cuidados registrados',
                  value: '${CareStore.instance.items.length}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Añadir Recordatorio',
          icon: Icons.add,
          onPressed: () => context.goAddReminder(),
        ),
        if (AppConfig.mostrarEnDesarrollo) ...[
          const SizedBox(height: 24),
          SectionHeader(title: 'Más sobre ${pet.name}'),
          const SizedBox(height: 12),
          _LinkTile(
            icon: Icons.folder_special_outlined,
            color: AppColors.certificates,
            title: 'Certificados y documentos',
            subtitle: 'Vacunas, carnet, perro de compañía',
            onTap: () => context.goCertificates(),
          ),
          const SizedBox(height: 10),
          _LinkTile(
            icon: Icons.timeline_outlined,
            color: AppColors.growth,
            title: 'Historial de crecimiento',
            subtitle: 'Fotos, peso y etapas',
            onTap: () => context.goGrowth(),
          ),
          const SizedBox(height: 10),
          _LinkTile(
            icon: Icons.celebration_outlined,
            color: AppColors.memories,
            title: 'Eventos significativos',
            subtitle: 'Cumpleaños y recuerdos',
            onTap: () => context.goEvents(),
          ),
          const SizedBox(height: 10),
          _LinkTile(
            icon: Icons.diversity_3_outlined,
            color: AppColors.family,
            title: 'Familia compartida',
            subtitle: 'Quién administra a la mascota',
            onTap: () => context.goFamily(),
          ),
        ],
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendaTab extends StatelessWidget {
  const _AgendaTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: 'Añadir Recordatorio',
          icon: Icons.add,
          onPressed: () => context.goAddReminder(),
        ),
        const SizedBox(height: 20),
        Text(
          'Próximos Recordatorios',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._tarjetas(context, [
          for (final r in RemindersStore.instance.upcoming)
            MockCareItem(
              title: r.title,
              subtitle: r.whenLabel,
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.primary,
            ),
        ], 'Sin recordatorios pendientes.'),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Historial clínico',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._tarjetas(context, [
          for (final r in CareStore.instance.items) r.toItem(),
        ], 'Todavía no hay cuidados registrados.'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Lista de tarjetas con mensaje cuando no hay nada que mostrar.
List<Widget> _tarjetas(
  BuildContext context,
  List<MockCareItem> items,
  String vacio,
) {
  if (items.isEmpty) {
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(vacio, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    ];
  }
  return [
    for (final item in items)
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CareItemCard(item: item),
      ),
  ];
}
