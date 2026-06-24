import 'package:agenda_pet/core/mocks/plan_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Confirmación de compra: el usuario ya es PRO.
class SubscriptionSuccessScreen extends StatelessWidget {
  const SubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 88),
                  ),
                  Positioned(
                    top: 4,
                    right: 24,
                    child: Icon(Icons.celebration,
                        color: AppColors.tips.withValues(alpha: 0.9), size: 28),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 28,
                    child: Icon(Icons.auto_awesome,
                        color: AppColors.memories.withValues(alpha: 0.8),
                        size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '¡Ahora eres PRO! 🎉',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gracias por apoyar a Agenda Pet. Ya tienes todo desbloqueado.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final benefit in PlanMockData.proBenefits.take(3))
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20),
                          title: Text(benefit),
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Empezar a usar PRO',
                icon: Icons.arrow_forward,
                onPressed: () => context.goDashboardActive(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
