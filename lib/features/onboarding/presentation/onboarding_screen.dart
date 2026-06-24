import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/onboarding/presentation/widgets/pets_illustration.dart';
import 'package:agenda_pet/shared/widgets/animated_entrance.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/paw_print_background.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PawPrintBackground(
        color: AppColors.primary,
        opacity: 0.05,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                const AppLogo(iconSize: 32),
                const Spacer(),
                const AnimatedEntrance(child: PetsIllustration()),
                const SizedBox(height: 32),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 120),
                  child: Text(
                    '¡Bienvenido a Agenda Pet!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Organiza y cuida a tus mascotas fácilmente',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                const SizedBox(height: 28),
                const AnimatedEntrance(
                  delay: Duration(milliseconds: 280),
                  child: Row(
                    children: [
                    Expanded(
                      child: _FeatureHighlight(
                        icon: Icons.notifications_active_outlined,
                        label: 'Recordatorios',
                        color: AppColors.actionCalendar,
                      ),
                    ),
                    Expanded(
                      child: _FeatureHighlight(
                        icon: Icons.timeline_outlined,
                        label: 'Crecimiento',
                        color: AppColors.growth,
                      ),
                    ),
                    Expanded(
                      child: _FeatureHighlight(
                        icon: Icons.tips_and_updates_outlined,
                        label: 'Tips',
                        color: AppColors.tips,
                      ),
                    ),
                  ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: '¡Comenzar!',
                  onPressed: () => context.goRegister(),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => context.goLogin(),
                  child: const Text('Ya tengo cuenta · Iniciar sesión'),
                ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  const _FeatureHighlight({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
