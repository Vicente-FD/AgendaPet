import 'package:agenda_pet/core/mocks/home_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/reminder_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ficha de Carolina — placeholder Fase 1 (sin tabs internos funcionales).
class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pet = HomeMockData.activePet;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(
                Icons.pets,
                size: 48,
                color: AppColors.primary,
              ),
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
          const _TabPlaceholder(),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Añadir Recordatorio',
            icon: Icons.add,
            onPressed: () {},
          ),
          const SizedBox(height: 24),
          Text(
            'Próximos Recordatorios',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...HomeMockData.upcomingReminders.map(
            (reminder) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReminderCard(reminder: reminder),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          _TabChip(label: 'Perfil', selected: true),
          _TabChip(label: 'Agenda', selected: false),
          _TabChip(label: 'Historial', selected: false),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
