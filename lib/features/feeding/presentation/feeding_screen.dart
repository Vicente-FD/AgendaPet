import 'package:agenda_pet/core/mocks/feeding_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/shared/widgets/paw_print_background.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Alimentación: alimento registrado, recordatorio de compra y calculadora de
/// ración según peso, raza y nivel de actividad. Todo con datos mock (frontend).
class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  static const _plan = FeedingMockData.currentPlan;

  late double _weightKg = _plan.weightKg;
  late ActivityLevel _activity = _plan.activity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Alimentación'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const _PlanSummaryCard(plan: _plan),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Próxima compra'),
          const SizedBox(height: 12),
          _PurchaseCard(plan: _plan, onRemind: _remindPurchase),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Dosis recomendada'),
          const SizedBox(height: 12),
          _DoseCalculator(
            plan: _plan,
            weightKg: _weightKg,
            activity: _activity,
            onWeightChanged: (v) => setState(() => _weightKg = v),
            onActivityChanged: (a) => setState(() => _activity = a),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Tabla de referencia'),
          const SizedBox(height: 12),
          const _GuidelineTable(),
          const SizedBox(height: 12),
          Text(
            'Valores referenciales para alimento seco. Próximamente se ajustarán '
            'automáticamente según raza, edad y condición corporal.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Registrar alimento',
            icon: Icons.add,
            onPressed: () => context.goAddFeeding(),
          ),
        ],
      ),
    );
  }

  void _remindPurchase() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Te recordaremos comprar alimento a tiempo 🛒'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.feeding,
        ),
      );
  }
}

/// Tarjeta superior con degradado: alimento actual de la mascota.
class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.plan});

  final FeedingPlan plan;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.feeding, Color(0xFFE65100)],
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.restaurant_outlined,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${plan.brand} · ${plan.foodName}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Alimento de ${plan.petName}',
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
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GlassChip(icon: Icons.set_meal_outlined, label: plan.kind),
                    _GlassChip(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Saco ${_kg(plan.bagSizeKg)}'),
                    _GlassChip(
                        icon: Icons.monitor_weight_outlined,
                        label: '${_kg(plan.weightKg)} · ${plan.breed}'),
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

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado del saco actual + periodo de compra.
class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.plan, required this.onRemind});

  final FeedingPlan plan;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final low = plan.daysRemaining <= 10;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Quedan ~${(plan.remainingFraction * 100).round()}% del saco',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (low ? AppColors.actionServices : AppColors.feeding)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${plan.daysRemaining} días',
                    style: TextStyle(
                      color: low ? AppColors.actionServices : AppColors.feeding,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: plan.remainingFraction,
                minHeight: 10,
                backgroundColor: context.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(
                  low ? AppColors.actionServices : AppColors.feeding,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PurchaseRow(
              icon: Icons.event_available_outlined,
              label: 'Próxima compra estimada',
              value: plan.nextPurchaseLabel,
            ),
            const SizedBox(height: 10),
            _PurchaseRow(
              icon: Icons.history_outlined,
              label: 'Última compra',
              value: plan.lastPurchaseLabel,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRemind,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: const Text('Recordarme la compra'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.feeding,
                side: const BorderSide(color: AppColors.feeding),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.feeding),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Calculadora de ración: se recalcula al mover el peso o cambiar la actividad.
class _DoseCalculator extends StatelessWidget {
  const _DoseCalculator({
    required this.plan,
    required this.weightKg,
    required this.activity,
    required this.onWeightChanged,
    required this.onActivityChanged,
  });

  final FeedingPlan plan;
  final double weightKg;
  final ActivityLevel activity;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<ActivityLevel> onActivityChanged;

  @override
  Widget build(BuildContext context) {
    final grams = FeedingMockData.recommendedDailyGrams(weightKg, activity);
    final perMeal = (grams / 2 / 5).round() * 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resultado destacado.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.feeding.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    '$grams g',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.feeding,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'al día · ~$perMeal g por toma (2 tomas)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Peso',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${weightKg.toStringAsFixed(weightKg % 1 == 0 ? 0 : 1)} kg',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.feeding,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.feeding,
                thumbColor: AppColors.feeding,
                overlayColor: AppColors.feeding.withValues(alpha: 0.15),
                inactiveTrackColor: context.surfaceMuted,
              ),
              child: Slider(
                value: weightKg.clamp(1, 50),
                min: 1,
                max: 50,
                divisions: 98,
                label: '${weightKg.round()} kg',
                onChanged: (v) => onWeightChanged(v),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nivel de actividad',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final level in ActivityLevel.values)
                  ChoiceChip(
                    label: Text(level.label),
                    selected: activity == level,
                    onSelected: (_) => onActivityChanged(level),
                    selectedColor: AppColors.feeding.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: activity == level
                          ? AppColors.feeding
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    showCheckmark: false,
                    side: BorderSide(
                      color: activity == level
                          ? AppColors.feeding
                          : context.surfaceMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Calculado para ${plan.breed} (${plan.species}). Consulta a tu '
                    'veterinario para una ración exacta.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabla guía peso → ración (referencial).
class _GuidelineTable extends StatelessWidget {
  const _GuidelineTable();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < FeedingMockData.guideline.length; i++) ...[
              if (i > 0) Divider(height: 1, color: context.surfaceMuted),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        FeedingMockData.guideline[i].weightRange,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        FeedingMockData.guideline[i].dailyAmount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        FeedingMockData.guideline[i].meals,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _kg(double v) =>
    '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)} kg';
