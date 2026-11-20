import 'dart:async';

import 'package:agenda_pet/core/location/location_service.dart';
import 'package:agenda_pet/core/mocks/walks_mock_data.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/route_map.dart';
import 'package:agenda_pet/features/walks/presentation/widgets/walk_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

/// Paseo en vivo con **mapa real** (OpenStreetMap) y **GPS real** (geolocator):
/// sigue tu posición, dibuja el recorrido y calcula distancia/tiempo reales.
class LiveWalkScreen extends StatefulWidget {
  const LiveWalkScreen({super.key});

  @override
  State<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends State<LiveWalkScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  LocationStatus? _status; // null = comprobando permiso
  LatLng? _current;
  final List<LatLng> _traveled = [];
  double _distanceM = 0;
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  StreamSubscription<LatLng>? _sub;
  bool _paused = false;
  bool _sharing = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final status = await LocationService.ensurePermission();
    if (!mounted) return;
    setState(() => _status = status);
    if (status != LocationStatus.granted) return;

    final start = await LocationService.current();
    if (!mounted) return;
    if (start != null) {
      setState(() {
        _current = start;
        _traveled.add(start);
      });
      _moveCamera(start, 16);
    }
    _watch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_paused) setState(() {});
    });
    _sub = LocationService.positionStream().listen(_onPosition, onError: (_) {});
  }

  void _onPosition(LatLng p) {
    if (!mounted || _paused) return;
    final prev = _current;
    if (prev != null) {
      final d = LocationService.distanceMeters(prev, p);
      if (d.isFinite && d < 250) _distanceM += d; // filtra saltos de GPS
    }
    setState(() {
      _current = p;
      _traveled.add(p);
    });
    _moveCamera(p, null);
  }

  void _moveCamera(LatLng p, double? zoom) {
    try {
      _mapController.move(p, zoom ?? _mapController.camera.zoom);
    } catch (_) {
      // el mapa aún no terminó de montarse
    }
  }

  Future<void> _retry() async {
    setState(() => _status = null);
    await _start();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _watch.stop();
    } else {
      _watch.start();
    }
  }

  void _toggleShare(bool value) {
    setState(() => _sharing = value);
    _snack(
      value
          ? 'Compartiendo ubicación en tiempo real'
          : 'Dejaste de compartir la ubicación',
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.walk,
        ),
      );
  }

  String _fmtTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _pulse.dispose();
    _ticker?.cancel();
    _sub?.cancel();
    _mapController.dispose();
    _watch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final km = _distanceM / 1000;
    final seconds = _watch.elapsed.inSeconds;
    final paceSec = km > 0.02 ? (seconds / km).round() : null;
    final tracking = _status == LocationStatus.granted;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapH =
              (constraints.maxHeight - 320).clamp(220.0, 900.0).toDouble();
          return Column(
            children: [
              SizedBox(
                height: mapH,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RouteMap(
                        traveled: _traveled.length >= 2 ? _traveled : null,
                        currentPosition: _current,
                        interactive: true,
                        showEndpoints: false,
                        height: null,
                        borderRadius: 0,
                        mapController: _mapController,
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
                            _LiveBadge(
                              pulse: _pulse,
                              tracking: tracking && _sharing && !_paused,
                              paused: _paused,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_paused) const Center(child: _PausedChip()),
                    if (_status == null)
                      const Center(child: CircularProgressIndicator()),
                    if (_status != null && !tracking)
                      _PermissionOverlay(status: _status!, onRetry: _retry),
                  ],
                ),
              ),
              Expanded(
                child: _StatsPanel(
                  distance: km,
                  timeLabel: _fmtTime(seconds),
                  paceLabel: paceSec != null ? _fmtTime(paceSec) : '--:--',
                  paused: _paused,
                  sharing: _sharing,
                  tracking: tracking,
                  onTogglePause: _togglePause,
                  onToggleShare: _toggleShare,
                  onFinish: () => _showFinishSheet(km, seconds),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFinishSheet(double km, int seconds) {
    _watch.stop();
    _sub?.pause();
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
                    child: const Icon(Icons.flag_rounded, color: AppColors.walk),
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
                  _snack('Paseo guardado en el historial 🐾');
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar paseo'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.walk),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  if (!_paused) {
                    _watch.start();
                    _sub?.resume();
                  }
                },
                child: const Text('Seguir paseando'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.distance,
    required this.timeLabel,
    required this.paceLabel,
    required this.paused,
    required this.sharing,
    required this.tracking,
    required this.onTogglePause,
    required this.onToggleShare,
    required this.onFinish,
  });

  final double distance;
  final String timeLabel;
  final String paceLabel;
  final bool paused;
  final bool sharing;
  final bool tracking;
  final VoidCallback onTogglePause;
  final ValueChanged<bool> onToggleShare;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
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
                      WalksMockData.walkers.first.name.characters.first,
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
                          'Paseando a ${WalksMockData.petName}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          tracking ? 'Ubicación en vivo' : 'Ubicación no activa',
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
              Row(
                children: [
                  WalkStat(
                    icon: Icons.straighten_rounded,
                    value: distance.toStringAsFixed(2),
                    label: 'km',
                  ),
                  WalkStat(
                    icon: Icons.timer_outlined,
                    value: timeLabel,
                    label: 'tiempo',
                  ),
                  WalkStat(
                    icon: Icons.speed_rounded,
                    value: paceLabel,
                    label: 'min/km',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Material(
                color: context.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                child: SwitchListTile(
                  value: sharing,
                  onChanged: tracking ? onToggleShare : null,
                  activeThumbColor: AppColors.walk,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  secondary:
                      const Icon(Icons.my_location_rounded, color: AppColors.walk),
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
                      onPressed: tracking ? onTogglePause : null,
                      icon: Icon(
                        paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      ),
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
  const _LiveBadge({
    required this.pulse,
    required this.tracking,
    required this.paused,
  });

  final AnimationController pulse;
  final bool tracking;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final label = paused
        ? 'PAUSADO'
        : tracking
            ? 'EN VIVO'
            : 'SIN GPS';
    final color = tracking && !paused ? Colors.red : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) => LivePulseDot(t: pulse.value, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
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

class _PermissionOverlay extends StatelessWidget {
  const _PermissionOverlay({required this.status, required this.onRetry});

  final LocationStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (status) {
      LocationStatus.denied => (
          'Permiso de ubicación denegado',
          'Permite el acceso a la ubicación para registrar el recorrido en el mapa.',
        ),
      LocationStatus.serviceDisabled => (
          'Ubicación desactivada',
          'Activa la ubicación de tu dispositivo para iniciar el paseo.',
        ),
      _ => (
          'Ubicación no disponible',
          'Este dispositivo no entrega ubicación. Puedes ver el mapa, pero no se registrará el recorrido.',
        ),
    };
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: AppColors.actionServices),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
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
