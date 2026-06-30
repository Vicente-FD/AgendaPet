import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/session/app_session.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/ad_banner.dart';
import 'package:agenda_pet/shared/widgets/app_bottom_nav.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/quick_action_tile.dart';
import 'package:flutter/material.dart';

/// Home de Ernesto. Aún no tiene mascotas registradas.
class DashboardEmptyScreen extends StatefulWidget {
  const DashboardEmptyScreen({super.key});

  @override
  State<DashboardEmptyScreen> createState() => _DashboardEmptyScreenState();
}

class _DashboardEmptyScreenState extends State<DashboardEmptyScreen> {
  @override
  void initState() {
    super.initState();
    AppSession.homeRoute = AppRoutes.dashboardEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.goNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goSettings(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Hola, Ernesto',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comienza agregando tu primera mascota',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          _EmptyPetCard(onTap: () => context.goAddPet()),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              QuickActionTile(
                label: 'Alimentación',
                icon: Icons.restaurant_outlined,
                color: AppColors.feeding,
                onTap: () => context.goAddPet(),
              ),
              QuickActionTile(
                label: 'Vacunas',
                icon: Icons.vaccines_outlined,
                color: AppColors.actionVaccines,
                onTap: () => context.goAddPet(),
              ),
              QuickActionTile(
                label: 'Medicinas',
                icon: Icons.medication_outlined,
                color: AppColors.actionMedicines,
                onTap: () => context.goAddPet(),
              ),
              QuickActionTile(
                label: 'Servicios',
                icon: Icons.home_repair_service_outlined,
                color: AppColors.actionServices,
                onTap: () => context.goAddPet(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AdBanner(),
          const SizedBox(height: 16),
          const _AllClearCard(),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Agregar primera mascota',
            icon: Icons.add,
            onPressed: () => context.goAddPet(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(
        currentIndex: 0,
        homeRoute: AppRoutes.dashboardEmpty,
      ),
    );
  }
}

class _EmptyPetCard extends StatelessWidget {
  const _EmptyPetCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sin mascotas aún',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Toca para registrar tu primera mascota',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _AllClearCard extends StatelessWidget {
  const _AllClearCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_outlined,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              '¡Todo al día!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'No tienes eventos próximos en los siguientes 30 días.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
