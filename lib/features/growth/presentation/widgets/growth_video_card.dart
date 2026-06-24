import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tarjeta del "Video resumen" del crecimiento. Es una función PRO: si el
/// usuario es Free, muestra un candado que lleva a la suscripción.
class GrowthVideoCard extends StatelessWidget {
  const GrowthVideoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final isPro = AppSettings.instance.isPro;
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              const _CollageThumbnail(),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (isPro) {
                        _showGenerating(context);
                      } else {
                        context.goSubscription();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '0:30',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (!isPro)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFFFFB300),
                                      Color(0xFFF57F17),
                                    ]),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock,
                                          color: Colors.white, size: 12),
                                      SizedBox(width: 3),
                                      Text('PRO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          )),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPro ? Icons.play_arrow_rounded : Icons.lock,
                                color: AppColors.growth,
                                size: 32,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Mi mascota a través del tiempo',
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
                            isPro
                                ? 'Toca para generar tu video resumen'
                                : 'Hazte PRO para crear el video resumen',
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
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenerating(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Generando tu video resumen… te avisaremos al terminar'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.growth,
        ),
      );
  }
}

class _CollageThumbnail extends StatelessWidget {
  const _CollageThumbnail();

  @override
  Widget build(BuildContext context) {
    const tints = [
      Color(0xFF80CBC4),
      Color(0xFF4DB6AC),
      Color(0xFF26A69A),
      Color(0xFF00897B),
    ];
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final tint in tints)
            Container(
              color: tint,
              child: Icon(
                Icons.pets,
                color: Colors.white.withValues(alpha: 0.4),
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
