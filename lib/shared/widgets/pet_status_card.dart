import 'dart:typed_data';

import 'package:agenda_pet/core/mocks/home_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/paw_print_background.dart';
import 'package:agenda_pet/shared/widgets/pet_avatar.dart';
import 'package:agenda_pet/shared/widgets/pressable.dart';
import 'package:flutter/material.dart';

class PetStatusCard extends StatelessWidget {
  const PetStatusCard({
    super.key,
    required this.pet,
    this.onTap,
    this.imageBytes,
  });

  final MockPet pet;
  final VoidCallback? onTap;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: PawPrintBackground(
            opacity: 0.08,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PetAvatar(
                    imageBytes: imageBytes,
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pet.pendingTasks} tareas pendientes',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
