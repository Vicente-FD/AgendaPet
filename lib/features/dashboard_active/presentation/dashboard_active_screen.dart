import 'package:agenda_pet/core/mocks/home_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/app_bottom_nav.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/pet_status_card.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/quick_action_tile.dart';
import 'package:agenda_pet/shared/widgets/reminder_card.dart';
import 'package:flutter/material.dart';

class DashboardActiveScreen extends StatelessWidget {
  const DashboardActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const AppLogo(),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Hola, ${HomeMockData.userName}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Qué necesitas hoy?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          PetStatusCard(
            pet: HomeMockData.activePet,
            onTap: () => context.goPetProfile(),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              QuickActionTile(
                label: 'Agenda',
                icon: Icons.calendar_month_outlined,
                color: AppColors.actionCalendar,
                onTap: () => context.goAgenda(),
              ),
              QuickActionTile(
                label: 'Vacunas',
                icon: Icons.vaccines_outlined,
                color: AppColors.actionVaccines,
                onTap: () => context.goVaccines(),
              ),
              QuickActionTile(
                label: 'Medicinas',
                icon: Icons.medication_outlined,
                color: AppColors.actionMedicines,
                onTap: () => context.goMedicines(),
              ),
              QuickActionTile(
                label: 'Servicios',
                icon: Icons.home_repair_service_outlined,
                color: AppColors.actionServices,
                onTap: () => context.goServices(),
              ),
            ],
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Agregar Mascota',
            icon: Icons.add,
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
