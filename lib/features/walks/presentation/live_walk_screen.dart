import 'package:agenda_pet/core/mocks/walks_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/route_map.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/walk_stat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Paseo en vivo: mapa con el recorrido avanzando, indicador de ubicación
/// compartida en tiempo real y métricas que suben. Todo simulado (frontend).
class LiveWalkScreen extends StatefulWidget {
  const LiveWalkScreen({super.key});

  @override
  State<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends State<LiveWalkScreen>
    with TickerProviderStateMixin {
  // Avanza por la ruta a lo largo de ~24 s (demo).
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..forward();

  // Pulso del punto "EN VIVO".
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  bool _paused = false;
  bool _sharing = true;

  @override
  void dispose() {
    _progress.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _progress.stop();
    } else if (_progress.value < 1) {
      _progress.forward();
    }
  }

  String _fmtTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // El mapa ocupa el alto disponible menos el panel, con un piso y
          // techo razonables. Si la ventana es muy baja (p. ej. con la consola
          // abierta), el conjunto hace scroll en vez de dejar el mapa en 0px.
          final vh = constraints.maxHeight;
          final mapHeight =
              (vh.isFinite ? vh - 300.0 : 360.0).clamp(200.0, 640.0);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: mapHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RouteMap(
                          points: WalksMockData.liveRoute,
                          progressAnimation: _progress,
                          height: mapHeight,
                          borderRadius: 0,
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _CircleButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => context.pop(),
                              ),
                              const Spacer(),
                              _LiveBadge(pulse: _pulse, sharing: _sharing),
                            ],
                          ),
                        ),
                      ),
                      if (_paused)
                        const Center(
                          child: _PausedChip(),
                        ),
                    ],
                  ),
                ),
                _StatsPanel(
                  progress: _progress,
                  paused: _paused,
                  sharing: _sharing,
                  onTogglePause: _togglePause,
                  onToggleShare: (v) {
                    setState(() => _sharing = v);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(v
                              ? 'Compartiendo ubicación en tiempo real'
                              : 'Dejaste de compartir la ubicación'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.walk,
                        ),
                      );
                  },
                  onFinish: () => _showFinishSheet(context),
                  fmtTime: _fmtTime,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFinishSheet(BuildContext context) {
    _progress.stop();
    final p = _progress.value.clamp(0.0, 1.0);
    final km = WalksMockData.liveTargetKm * p;
    final seconds = (WalksMockData.liveTargetSeconds * p).round();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.walk.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flag_rounded,
                        color: AppColors.walk),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Paseo terminado!',
                          style: Theme.of(sheetContext)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Recorrido de ${WalksMockData.petName}',
                          style: Theme.of(sheetContext)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  WalkStat(
                    icon: Icons.straighten_rounded,
                    value: '${km.toStringAsFixed(2)} km',
                    label: 'Distancia',
                  ),
                  WalkStat(
                    icon: Icons.timer_outlined,
                    value: _fmtTime(seconds),
                    label: 'Tiempo',
                  ),
                  WalkStat(
                    icon: Icons.local_fire_department_outlined,
                    value: '${(km * 55).round()} kcal',
                    label: 'Estimado',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.pop();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Paseo guardado en el historial 🐾'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.walk,
                      ),
                    );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar paseo'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.walk),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Seguir paseando'),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Si el usuario cerró la hoja sin guardar y el paseo no terminó, retoma.
      if (mounted && !_paused && _progress.value < 1) _progress.forward();
    });
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.progress,
    required this.paused,
    required this.sharing,
    required this.onTogglePause,
    required this.onToggleShare,
    required this.onFinish,
    required this.fmtTime,
  });

  final AnimationController progress;
  final bool paused;
  final bool sharing;
  final VoidCallback onTogglePause;
  final ValueChanged<bool> onToggleShare;
  final VoidCallback onFinish;
  final String Function(int) fmtTime;

  @override
  Widget build(BuildContext context) {
    final paceSecPerKm =
        WalksMockData.liveTargetSeconds / WalksMockData.liveTargetKm;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.walk.withValues(alpha: 0.18),
                    child: Text(
                      WalksMockData.liveWalker.characters.first,
                      style: const TextStyle(
                        color: AppColors.walk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${WalksMockData.liveWalker} está paseando',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'a ${WalksMockData.petName} · ${WalksMockData.liveWalkerRole}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: progress,
                builder: (context, _) {
                  final p = progress.value.clamp(0.0, 1.0);
                  final km = WalksMockData.liveTargetKm * p;
                  final seconds =
                      (WalksMockData.liveTargetSeconds * p).round();
                  return Row(
                    children: [
                      WalkStat(
                        icon: Icons.straighten_rounded,
                        value: km.toStringAsFixed(2),
                        label: 'km',
                      ),
                      WalkStat(
                        icon: Icons.timer_outlined,
                        value: fmtTime(seconds),
                        label: 'tiempo',
                      ),
                      WalkStat(
                        icon: Icons.speed_rounded,
                        value: fmtTime(paceSecPerKm.round()),
                        label: 'min/km',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Toggle de compartir ubicación.
              Material(
                color: context.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                child: SwitchListTile(
                  value: sharing,
                  onChanged: onToggleShare,
                  activeThumbColor: AppColors.walk,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  secondary: const Icon(Icons.my_location_rounded,
                      color: AppColors.walk),
                  title: const Text('Compartir ubicación en vivo'),
                  subtitle: Text(
                    sharing ? 'La familia ve el recorrido' : 'Ubicación oculta',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTogglePause,
                      icon: Icon(paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded),
                      label: Text(paused ? 'Reanudar' : 'Pausar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.walk,
                        side: const BorderSide(color: AppColors.walk),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onFinish,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Finalizar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.actionServices,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.pulse, required this.sharing});

  final AnimationController pulse;
  final bool sharing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) => LivePulseDot(
              t: pulse.value,
              color: sharing ? Colors.red : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            sharing ? 'EN VIVO' : 'PAUSADO',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}

class _PausedChip extends StatelessWidget {
  const _PausedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause_rounded, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(
            'Paseo en pausa',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
