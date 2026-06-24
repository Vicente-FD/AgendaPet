import 'package:agenda_pet/core/mocks/pets_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tira horizontal para alternar entre mascotas. El último chip agrega una nueva.
class PetSwitcher extends StatelessWidget {
  const PetSwitcher({
    super.key,
    required this.pets,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
  });

  final List<PetSummary> pets;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == pets.length) {
            return _AddChip(onTap: onAdd);
          }
          return _PetChip(
            pet: pets[index],
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _PetChip extends StatelessWidget {
  const _PetChip({
    required this.pet,
    required this.selected,
    required this.onTap,
  });

  final PetSummary pet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: pet.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? pet.accent : Colors.transparent,
                  width: 2.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(pet.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 4),
            Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? pet.accent : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Agregar',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
