import 'package:agenda_pet/core/mocks/walks_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/route_map.dart';
import 'package:agenda_pet/shared/widgets/animated_entrance.dart';
import 'package:agenda_pet/shared/widgets/paw_print_background.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Paseos: feed estilo Strava con el resumen semanal, los paseadores y la
/// actividad reciente. Desde aquí se inicia un paseo en vivo.
class WalksScreen extends StatelessWidget {
  const WalksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = WalksMockData.records;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Paseos'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const _WeeklyHero(),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Paseadores',
            actionLabel: 'Agregar',
            onAction: () => _showAddWalkerSheet(context),
          ),
          const SizedBox(height: 12),
          const _WalkersStrip(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Actividad reciente'),
          const SizedBox(height: 12),
          ...records.indexed.map(
            (e) => AnimatedEntrance(
              delay: AnimatedEntrance.stagger(e.$1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _WalkCard(
                  record: e.$2,
                  onTap: () => context.goWalkDetail(e.$2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta destacada con degradado: resumen de la semana + iniciar paseo.
class _WeeklyHero extends StatelessWidget {
  const _WeeklyHero();

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.walk, AppColors.walkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: PawPrintBackground(
          opacity: 0.1,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta semana',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeroStat(
                      value: WalksMockData.weeklyKm.toStringAsFixed(1),
                      suffix: ' km',
                      label: 'Distancia',
                    ),
                    const _HeroStat(
                      value: '${WalksMockData.weeklyWalks}',
                      label: 'Paseos',
                    ),
                    const _HeroStat(
                      value: '${WalksMockData.weeklyMinutes}',
                      suffix: ' min',
                      label: 'Tiempo',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.goLiveWalk(),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Iniciar paseo'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.walk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label, this.suffix = ''});

  final String value;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value$suffix',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
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

/// Fila horizontal de paseadores disponibles (familia + profesional).
class _WalkersStrip extends StatelessWidget {
  const _WalkersStrip();

  @override
  Widget build(BuildContext context) {
    final walkers = WalksMockData.walkers;
    return SizedBox(
      height: 162,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: walkers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _WalkerCard(walker: walkers[i]),
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  const _WalkerCard({required this.walker});

  final Walker walker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.surfaceMuted),
      ),
      child: Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: walker.avatarColor.withValues(alpha: 0.18),
            child: Text(
              walker.name.characters.first.toUpperCase(),
              style: TextStyle(
                color: walker.avatarColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            walker.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.tips, size: 14),
              const SizedBox(width: 2),
              Text(
                walker.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _MiniRoleChip(walker: walker),
        ],
      ),
      ),
    );
  }
}

class _MiniRoleChip extends StatelessWidget {
  const _MiniRoleChip({required this.walker});

  final Walker walker;

  @override
  Widget build(BuildContext context) {
    final color = walker.isProfessional ? AppColors.walk : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        walker.role,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Tarjeta de un paseo registrado (estilo Strava).
class _WalkCard extends StatelessWidget {
  const _WalkCard({required this.record, required this.onTap});

  final WalkRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: avatar + nombre + rol + fecha.
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        record.avatarColor.withValues(alpha: 0.18),
                    child: Text(
                      record.walkerName.characters.first.toUpperCase(),
                      style: TextStyle(
                        color: record.avatarColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                record.walkerName,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _RolePill(byWalker: record.byWalker),
                          ],
                        ),
                        Text(
                          'Paseó a ${record.petName} · ${record.dateLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RouteMap(points: record.route, height: 130),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InlineStat(
                    icon: Icons.straighten_rounded,
                    value: '${record.distanceKm.toStringAsFixed(1)} km',
                  ),
                  _InlineStat(
                    icon: Icons.timer_outlined,
                    value: record.durationLabel,
                  ),
                  _InlineStat(
                    icon: Icons.speed_rounded,
                    value: record.paceLabel,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.pets, size: 18, color: AppColors.walk),
                  const SizedBox(width: 6),
                  Text(
                    '${record.kudos}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'aplausos',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  Text(
                    'Ver recorrido',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.walk,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.walk, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddWalkerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: const _AddWalkerForm(),
    ),
  );
}

class _AddWalkerForm extends StatefulWidget {
  const _AddWalkerForm();

  @override
  State<_AddWalkerForm> createState() => _AddWalkerFormState();
}

class _AddWalkerFormState extends State<_AddWalkerForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Agregar paseador',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Se unirá a la familia y podrá iniciar paseos y compartir la '
              'ubicación de ${WalksMockData.petName} en tiempo real.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || !value.contains('@')
                  ? 'Correo inválido'
                  : null,
              decoration: InputDecoration(
                hintText: 'paseador@correo.cl',
                prefixIcon: const Icon(Icons.directions_walk_rounded),
                filled: true,
                fillColor: context.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                          Text('Invitación enviada a ${_emailController.text.trim()}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.walk,
                    ),
                  );
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar invitación'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.walk),
            ),
          ],
        ),
      ),
    );
  }
}
