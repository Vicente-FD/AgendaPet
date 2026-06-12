import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/onboarding/presentation/widgets/pets_illustration.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const AppLogo(iconSize: 32),
              const Spacer(),
              const PetsIllustration(),
              const SizedBox(height: 40),
              Text(
                '¡Bienvenido a Agenda Pet!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Organiza y cuida a tus mascotas fácilmente',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              PrimaryButton(
                label: '¡Comenzar!',
                onPressed: () => context.goDashboardActive(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
