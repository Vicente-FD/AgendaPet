import 'package:agenda_pet/core/mocks/pets_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista de todas las mascotas de la cuenta, leída del backend.
class PetsListScreen extends StatefulWidget {
  const PetsListScreen({super.key});

  @override
  State<PetsListScreen> createState() => _PetsListScreenState();
}

class _PetsListScreenState extends State<PetsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PetsStore.instance.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis mascotas'),
      ),
      body: ListenableBuilder(
        listenable: PetsStore.instance,
        builder: (context, _) {
          final store = PetsStore.instance;

          if (store.loading && store.pets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.error != null && store.pets.isEmpty) {
            return _EstadoVacio(
              icon: Icons.cloud_off_outlined,
              title: 'No pudimos cargar tus mascotas',
              message: store.error!,
              actionLabel: 'Reintentar',
              onAction: () => store.load(force: true),
            );
          }

          if (store.isEmpty) {
            return _EstadoVacio(
              icon: Icons.pets_outlined,
              title: 'Todavía no tienes mascotas',
              message: 'Agrega la primera para empezar a organizar su cuidado.',
              actionLabel: 'Agregar mascota',
              onAction: () => context.goAddPet(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => store.load(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                  children: [
                    for (var i = 0; i < store.pets.length; i++)
                      _PetCard(
                        pet: store.pets[i].toSummary(index: i),
                        onTap: () {
                          store.select(i);
                          context.goPetProfile();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Agregar mascota',
                  icon: Icons.add,
                  onPressed: () => context.goAddPet(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

  final PetSummary pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: pet.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(pet.emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 10),
              Text(
                pet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '${pet.species} · ${pet.age}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pet.pendingTasks > 0
                      ? pet.accent.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pet.pendingTasks > 0
                      ? '${pet.pendingTasks} pendientes'
                      : 'Todo al día',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: pet.pendingTasks > 0
                            ? pet.accent
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
