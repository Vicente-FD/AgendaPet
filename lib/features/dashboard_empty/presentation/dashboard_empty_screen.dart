import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/app_bottom_nav.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Vista de Ernesto — sin mascotas registradas (placeholder Fase 1).
class DashboardEmptyScreen extends StatelessWidget {
  const DashboardEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const AppLogo(),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.pets_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Hola, Ernesto',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no tienes mascotas registradas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Agregar Mascota',
              icon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
