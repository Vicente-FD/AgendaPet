import 'dart:typed_data';

import 'package:agenda_pet/core/mocks/care_mock_data.dart';
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
  Uint8List? _photo;

  Future<void> _changePhoto() async {
    final bytes = await showPhotoSourceSheet(context);
    if (bytes != null) setState(() => _photo = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final pet = CareMockData.petDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: PetAvatar(
              imageBytes: _photo,
              radius: 48,
              onAddPhoto: _changePhoto,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            pet.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            pet.species,
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
          if (_tabIndex == 0) _ProfileTab(pet: pet),
          if (_tabIndex == 1) const _AgendaTab(),
          if (_tabIndex == 2) const _HistoryTab(),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.pet});

  final MockPetDetail pet;

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
                _InfoRow(label: 'Raza', value: pet.breed),
                const Divider(height: 24),
                _InfoRow(label: 'Edad', value: pet.age),
                const Divider(height: 24),
                _InfoRow(label: 'Peso', value: pet.weight),
                const Divider(height: 24),
                _InfoRow(label: 'Microchip', value: pet.chip),
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
        const SizedBox(height: 24),
        SectionHeader(title: 'Más sobre ${pet.name}'),
        const SizedBox(height: 12),
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
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.6)),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...CareMockData.petAgendaItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CareItemCard(item: item),
          ),
        ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...CareMockData.historyItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CareItemCard(item: item),
          ),
        ),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
