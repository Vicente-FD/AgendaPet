import 'package:agenda_pet/core/mocks/plan_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:agenda_pet/shared/widgets/segmented_tabs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _annual = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Plan PRO'),
      ),
      body: ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (context, _) {
          return AppSettings.instance.isPro ? _buildManage(context) : _buildPaywall(context);
        },
      ),
    );
  }

  // ---------------------------------------------------------------- Paywall ---
  Widget _buildPaywall(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const _ProHero(),
        const SizedBox(height: 20),
        SegmentedTabs(
          labels: const ['Mensual', 'Anual'],
          selectedIndex: _annual ? 1 : 0,
          onSelected: (i) => setState(() => _annual = i == 1),
        ),
        const SizedBox(height: 16),
        _PriceCard(annual: _annual),
        const SizedBox(height: 20),
        const _ComparisonCard(),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Suscribirme · ${_annual ? PlanMockData.annualPrice : PlanMockData.monthlyPrice}',
          icon: Icons.workspace_premium,
          onPressed: () => context.goCheckout(),
        ),
        const SizedBox(height: 10),
        Text(
          'Pago simulado para demostración. Cancela cuando quieras.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------- Manage ---
  Widget _buildManage(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const _ProHero(active: true),
        const SizedBox(height: 20),
        Text(
          'Tus beneficios',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final benefit in PlanMockData.proBenefits)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle,
                        color: AppColors.primary),
                    title: Text(benefit),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.event_repeat_outlined),
            title: Text('Próxima renovación'),
            subtitle: Text('23 de julio 2026 · ${PlanMockData.monthlyPrice}${PlanMockData.monthlyPeriod}'),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              AppSettings.instance.setPro(false);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Suscripción cancelada (simulado)'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.actionServices,
                  ),
                );
            },
            icon: const Icon(Icons.cancel_outlined,
                color: AppColors.actionServices),
            label: const Text(
              'Cancelar suscripción',
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
    );
  }
}

class _ProHero extends StatelessWidget {
  const _ProHero({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFF57F17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            active ? '¡Eres PRO!' : 'Agenda Pet PRO',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? 'Gracias por apoyar a Agenda Pet 🐾'
                : 'Desbloquea todo el potencial de la app',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.annual});

  final bool annual;

  @override
  Widget build(BuildContext context) {
    final price = annual ? PlanMockData.annualPrice : PlanMockData.monthlyPrice;
    final period =
        annual ? PlanMockData.annualPeriod : PlanMockData.monthlyPeriod;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tips.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tips.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                period,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          if (annual) ...[
            const SizedBox(height: 4),
            Text(
              PlanMockData.annualEquivalent,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(flex: 5, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Text('Free',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PRO',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.tips,
                            fontWeight: FontWeight.w800,
                          )),
                ),
              ],
            ),
            const Divider(height: 20),
            for (final f in PlanMockData.features) ...[
              _FeatureRow(feature: f),
              if (f != PlanMockData.features.last) const Divider(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final PlanFeature feature;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            feature.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(flex: 2, child: Center(child: _cell(context, feature.free))),
        Expanded(flex: 2, child: Center(child: _cell(context, feature.pro, pro: true))),
      ],
    );
  }

  Widget _cell(BuildContext context, String value, {bool pro = false}) {
    if (value == 'yes') {
      return Icon(Icons.check_circle,
          color: pro ? AppColors.tips : AppColors.primary, size: 20);
    }
    if (value == 'no') {
      return Icon(Icons.remove,
          color: AppColors.textSecondary.withValues(alpha: 0.5), size: 18);
    }
    return Text(
      value,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: pro ? AppColors.tips : null,
          ),
    );
  }
}
