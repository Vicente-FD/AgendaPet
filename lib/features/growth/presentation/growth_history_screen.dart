import 'dart:typed_data';

import 'package:agenda_pet/core/mocks/growth_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/features/growth/presentation/widgets/before_after_slider.dart';
import 'package:agenda_pet/features/growth/presentation/widgets/growth_video_card.dart';
import 'package:agenda_pet/features/growth/presentation/widgets/weight_chart.dart';
import 'package:agenda_pet/shared/widgets/paw_print_background.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Historial de Crecimiento: línea de tiempo de fotos, peso y recuerdos.
class GrowthHistoryScreen extends StatelessWidget {
  const GrowthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = GrowthMockData.timeline;
    final newest = timeline.first;
    final oldest = timeline.last;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Historial de crecimiento'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const _MonthlySummaryCard(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Antes y ahora'),
          const SizedBox(height: 12),
          BeforeAfterSlider(
            before: _StagePanel(
              ageLabel: oldest.ageLabel,
              weight: oldest.weight,
              color: const Color(0xFFB2DFDB),
            ),
            after: _StagePanel(
              ageLabel: newest.ageLabel,
              weight: newest.weight,
              color: AppColors.growth,
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Evolución del peso'),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: WeightChart(points: GrowthMockData.weightSeries),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Video resumen'),
          const SizedBox(height: 12),
          const GrowthVideoCard(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Línea de tiempo'),
          const SizedBox(height: 12),
          for (var i = 0; i < timeline.length; i++)
            _TimelineTile(
              entry: timeline[i],
              isFirst: i == 0,
              isLast: i == timeline.length - 1,
            ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Agregar foto',
            icon: Icons.add_a_photo_outlined,
            onPressed: () => context.goAddGrowth(),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mi mascota a través del tiempo',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  GrowthMockData.monthlySummary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    _SummaryStat(
                      value:
                          '${GrowthMockData.weightStart} → ${GrowthMockData.weightCurrent}',
                      label: 'Peso',
                    ),
                    _SummaryStat(
                      value: '${GrowthMockData.photosCount}',
                      label: 'Fotos',
                    ),
                    _SummaryStat(
                      value: '${GrowthMockData.monthsTracked} meses',
                      label: 'Registrados',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}

/// Panel usado dentro del comparador Antes/Ahora. Como las fotos son
/// placeholders, muestra un fondo de color con la etapa (edad · peso).
class _StagePanel extends StatelessWidget {
  const _StagePanel({
    required this.ageLabel,
    required this.weight,
    required this.color,
  });

  final String ageLabel;
  final String weight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, color: Colors.white.withValues(alpha: 0.85), size: 36),
          const SizedBox(height: 8),
          Text(
            ageLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            weight,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final GrowthEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea + nodo del timeline.
          Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: isFirst
                    ? Colors.transparent
                    : AppColors.growth.withValues(alpha: 0.3),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.growth,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : AppColors.growth.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PhotoBox(
                        imageBytes: entry.imageBytes,
                        height: 72,
                        width: 72,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.dateLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _MeasureChip(
                                    icon: Icons.cake_outlined,
                                    label: entry.ageLabel),
                                _MeasureChip(
                                    icon: Icons.monitor_weight_outlined,
                                    label: entry.weight),
                                _MeasureChip(
                                    icon: Icons.straighten_outlined,
                                    label: entry.height),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.note,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
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
  }
}

class _MeasureChip extends StatelessWidget {
  const _MeasureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.growth.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.growth),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.growth,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Caja de foto: muestra la imagen si existe, o un placeholder gris si no.
class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.imageBytes,
    required this.height,
    this.width,
  });

  final Uint8List? imageBytes;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: imageBytes != null
            ? Image.memory(imageBytes!, fit: BoxFit.cover)
            : Container(
                color: context.surfaceMuted,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 28,
                ),
              ),
      ),
    );
  }
}
