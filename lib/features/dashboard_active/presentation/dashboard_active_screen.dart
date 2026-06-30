import 'package:agenda_pet/core/mocks/home_mock_data.dart';
import 'package:agenda_pet/core/mocks/notifications_mock_data.dart';
import 'package:agenda_pet/core/mocks/pets_mock_data.dart';
import 'package:agenda_pet/core/mocks/tips_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/ad_banner.dart';
import 'package:agenda_pet/shared/widgets/animated_entrance.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/paw_print_background.dart';
import 'package:agenda_pet/shared/widgets/pet_status_card.dart';
import 'package:agenda_pet/shared/widgets/pet_switcher.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/pro_badge.dart';
import 'package:agenda_pet/shared/widgets/quick_action_tile.dart';
import 'package:agenda_pet/shared/widgets/reminder_card.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:agenda_pet/shared/widgets/tip_card.dart';
import 'package:flutter/material.dart';

class DashboardActiveScreen extends StatefulWidget {
  const DashboardActiveScreen({super.key});

  @override
  State<DashboardActiveScreen> createState() => _DashboardActiveScreenState();
}

class _DashboardActiveScreenState extends State<DashboardActiveScreen> {
  int _selectedPet = 0;

  @override
  Widget build(BuildContext context) {
    final pet = PetsMockData.pets[_selectedPet];
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: AppSettings.instance,
              builder: (context, _) => AppSettings.instance.isPro
                  ? const ProBadge(compact: true)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          _NotificationBell(
            unread: NotificationsMockData.unreadCount,
            onTap: () => context.goNotifications(),
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
          const _GreetingHeader(name: HomeMockData.userName),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Tus mascotas',
            actionLabel: 'Ver todas',
            onAction: () => context.goPets(),
          ),
          const SizedBox(height: 8),
          PetSwitcher(
            pets: PetsMockData.pets,
            selectedIndex: _selectedPet,
            onSelected: (i) => setState(() => _selectedPet = i),
            onAdd: () => context.goAddPet(),
          ),
          const SizedBox(height: 12),
          PetStatusCard(
            pet: MockPet(
              name: pet.name,
              pendingTasks: pet.pendingTasks,
              species: pet.species,
            ),
            onTap: () => context.goPetProfile(),
          ),
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
                onTap: () => context.goFeeding(),
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
          const SizedBox(height: 16),
          const AdBanner(),
          const SizedBox(height: 16),
          TipCard(
            tip: TipsMockData.tipOfTheDay,
            compact: true,
            onTap: () => context.goTips(),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Próximos Recordatorios',
            actionLabel: 'Ver agenda',
            onAction: () => context.goAgenda(),
          ),
          const SizedBox(height: 12),
          ...HomeMockData.upcomingReminders.indexed.map(
            (entry) => AnimatedEntrance(
              delay: AnimatedEntrance.stagger(entry.$1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ReminderCard(reminder: entry.$2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Paseos',
            actionLabel: 'Ver todos',
            onAction: () => context.goWalks(),
          ),
          const SizedBox(height: 12),
          _WalkTeaserCard(
            onTap: () => context.goWalks(),
            onStart: () => context.goLiveWalk(),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recuerdos de tu mascota',
            actionLabel: 'Ver todo',
            onAction: () => context.goGrowth(),
          ),
          const SizedBox(height: 12),
          _GrowthTeaserCard(onTap: () => context.goGrowth()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickActionTile(
                  label: 'Eventos',
                  icon: Icons.celebration_outlined,
                  color: AppColors.memories,
                  onTap: () => context.goEvents(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionTile(
                  label: 'Familia',
                  icon: Icons.diversity_3_outlined,
                  color: AppColors.family,
                  onTap: () => context.goFamily(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Agregar Mascota',
            icon: Icons.add,
            onPressed: () => context.goAddPet(),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.notifications_outlined),
        ),
        if (unread > 0)
          // IgnorePointer: la insignia se solapa con el icono; sin esto
          // absorbería el toque y la campana no navegaría.
          Positioned(
            top: 8,
            right: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(
                  color: AppColors.actionServices,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Encabezado con degradado: saludo personalizado sobre fondo de huellas.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Toda la tarjeta de saludo abre el perfil del dueño (acceso directo).
        onTap: () => context.goUserProfile(),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: PawPrintBackground(
            opacity: 0.1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, $name 👋',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¿Qué necesitas hoy?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mi cuenta',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta destacada para iniciar/ver paseos (estilo Strava).
class _WalkTeaserCard extends StatelessWidget {
  const _WalkTeaserCard({required this.onTap, required this.onStart});

  final VoidCallback onTap;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.walk, AppColors.walkAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: PawPrintBackground(
            opacity: 0.1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.directions_walk_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registra un paseo',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Guarda el recorrido y la ubicación en vivo',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.walk,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Iniciar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrowthTeaserCard extends StatelessWidget {
  const _GrowthTeaserCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.growth, Color(0xFF004D40)],
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.timeline_outlined,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de crecimiento',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mira cómo ha cambiado con el tiempo',
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
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
