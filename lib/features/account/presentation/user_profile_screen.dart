import 'dart:typed_data';

import 'package:agenda_pet/core/mocks/user_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/animated_count.dart';
import 'package:agenda_pet/shared/widgets/pet_avatar.dart';
import 'package:agenda_pet/shared/widgets/photo_picker_field.dart';
import 'package:agenda_pet/shared/widgets/pro_badge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Uint8List? _photo;

  Future<void> _changePhoto() async {
    final bytes = await showPhotoSourceSheet(context);
    if (bytes != null) setState(() => _photo = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mi cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goSettings(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: PetAvatar(
              imageBytes: _photo,
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              onAddPhoto: _changePhoto,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(
                  UserMockData.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  UserMockData.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 10),
                ListenableBuilder(
                  listenable: AppSettings.instance,
                  builder: (context, _) => AppSettings.instance.isPro
                      ? const ProBadge()
                      : const _FreeBadge(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _StatsRow(),
          const SizedBox(height: 24),
          _LinkTile(
            icon: Icons.workspace_premium_outlined,
            color: AppColors.tips,
            title: 'Mi suscripción',
            subtitle: 'Plan, facturación y beneficios',
            onTap: () => context.goSubscription(),
          ),
          const SizedBox(height: 10),
          _LinkTile(
            icon: Icons.diversity_3_outlined,
            color: AppColors.family,
            title: 'Familia compartida',
            subtitle: 'Personas que administran tus mascotas',
            onTap: () => context.goFamily(),
          ),
          const SizedBox(height: 10),
          _LinkTile(
            icon: Icons.settings_outlined,
            color: AppColors.actionCalendar,
            title: 'Ajustes',
            subtitle: 'Tema, notificaciones e idioma',
            onTap: () => context.goSettings(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.goLogin(),
              icon: const Icon(Icons.logout, color: AppColors.actionServices),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: AppColors.actionServices),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                    color: AppColors.actionServices.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  const _FreeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Plan Free',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            value: UserMockData.petsCount,
            label: 'Mascotas',
            icon: Icons.pets,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: UserMockData.remindersCount,
            label: 'Recordatorios',
            icon: Icons.notifications_active_outlined,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: UserMockData.photosCount,
            label: 'Fotos',
            icon: Icons.photo_library_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            AnimatedCount(
              value: value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
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
