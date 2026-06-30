import 'package:agenda_pet/core/mocks/walks_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/route_map.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/walk_stat.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Detalle de un paseo guardado: recorrido completo, métricas y parciales.
class WalkDetailScreen extends StatelessWidget {
  const WalkDetailScreen({super.key, this.record});

  /// Si no se pasa, usa el paseo más reciente (p. ej. desde el menú dev).
  final WalkRecord? record;

  @override
  Widget build(BuildContext context) {
    final walk = record ?? WalksMockData.records.first;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recorrido'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Encabezado con paseador.
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: walk.avatarColor.withValues(alpha: 0.18),
                child: Text(
                  walk.walkerName.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: walk.avatarColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      walk.walkerName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Paseó a ${walk.petName} · ${walk.dateLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              _RolePill(byWalker: walk.byWalker),
            ],
          ),
          const SizedBox(height: 16),
          RouteMap(points: walk.route, height: 240),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  WalkStat(
                    icon: Icons.straighten_rounded,
                    value: '${walk.distanceKm.toStringAsFixed(1)} km',
                    label: 'Distancia',
                  ),
                  WalkStat(
                    icon: Icons.timer_outlined,
                    value: walk.durationLabel,
                    label: 'Tiempo',
                  ),
                  WalkStat(
                    icon: Icons.speed_rounded,
                    value: walk.paceLabel,
                    label: 'Ritmo',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Parciales por km'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final split in WalksMockData.splits) ...[
                    _SplitRow(split: split),
                    if (split != WalksMockData.splits.last)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Le diste aplausos a ${walk.walkerName} 👏'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.walk,
                  ),
                );
            },
            icon: const Icon(Icons.pets),
            label: Text('Dar aplausos (${walk.kudos})'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.walk,
              side: const BorderSide(color: AppColors.walk),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.split});

  final ({String km, String time, double intensity}) split;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            split.km,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: split.intensity,
              minHeight: 10,
              backgroundColor: context.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation(AppColors.walk),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          split.time,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.byWalker});

  final bool byWalker;

  @override
  Widget build(BuildContext context) {
    final color = byWalker ? AppColors.walk : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        byWalker ? 'Paseador' : 'Familia',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
