import 'dart:math' as math;

import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Configuración de mapas. En tests se desactivan los tiles de red
/// (`tilesEnabled = false`) para no hacer peticiones HTTP durante los widgets.
abstract final class MapConfig {
  static bool tilesEnabled = true;
  static const String osmUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgent = 'cl.agendapet.app';
  static const LatLng defaultCenter = LatLng(-33.4489, -70.6693); // Santiago
}

/// Mapa real (OpenStreetMap) con la ruta de un paseo.
///
/// - `points`: la ruta (completa) a dibujar.
/// - `traveled`: tramo recorrido resaltado (paseo en vivo).
/// - `currentPosition`: posición actual (marcador que se mueve).
/// - `interactive`: permite pan/zoom (mapas grandes) o lo bloquea (miniaturas).
class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    this.points = const [],
    this.traveled,
    this.currentPosition,
    this.color = AppColors.walk,
    this.height = 200,
    this.borderRadius = 16,
    this.interactive = false,
    this.showEndpoints = true,
    this.mapController,
  });

  final List<LatLng> points;
  final List<LatLng>? traveled;
  final LatLng? currentPosition;
  final Color color;
  final double? height;
  final double borderRadius;
  final bool interactive;
  final bool showEndpoints;
  final MapController? mapController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final focus = <LatLng>[
      ...points,
      ?currentPosition,
    ];
    final live = currentPosition != null;

    final map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCameraFit: focus.length >= 2
            ? CameraFit.coordinates(
                coordinates: focus,
                padding: const EdgeInsets.all(28),
                maxZoom: 17,
              )
            : null,
        initialCenter: focus.isNotEmpty ? focus.first : MapConfig.defaultCenter,
        initialZoom: 15,
        backgroundColor:
            isDark ? const Color(0xFF1B2430) : const Color(0xFFE9F0F5),
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        if (MapConfig.tilesEnabled)
          TileLayer(
            urlTemplate: MapConfig.osmUrlTemplate,
            userAgentPackageName: MapConfig.userAgent,
            maxZoom: 19,
          ),
        if (points.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                color: live ? color.withValues(alpha: 0.30) : color,
                strokeWidth: 5,
                borderStrokeWidth: 1,
                borderColor: Colors.white.withValues(alpha: 0.7),
              ),
              if (traveled != null && traveled!.length >= 2)
                Polyline(points: traveled!, color: color, strokeWidth: 6),
            ],
          ),
        MarkerLayer(markers: _markers()),
        const _OsmAttribution(),
      ],
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: map,
    );
    return height == null
        ? clipped
        : SizedBox(height: height, width: double.infinity, child: clipped);
  }

  List<Marker> _markers() {
    final markers = <Marker>[];
    if (showEndpoints && points.isNotEmpty) {
      markers.add(
        Marker(
          point: points.first,
          width: 20,
          height: 20,
          child: const _EndpointDot(color: Color(0xFF2ECC71)),
        ),
      );
      if (currentPosition == null && points.length >= 2) {
        markers.add(
          Marker(
            point: points.last,
            width: 30,
            height: 30,
            alignment: Alignment.topCenter,
            child: const Icon(Icons.place, color: AppColors.actionServices, size: 30),
          ),
        );
      }
    }
    if (currentPosition != null) {
      markers.add(
        Marker(
          point: currentPosition!,
          width: 28,
          height: 28,
          child: _LiveMarker(color: color),
        ),
      );
    }
    return markers;
  }
}

class _EndpointDot extends StatelessWidget {
  const _EndpointDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
    );
  }
}

class _LiveMarker extends StatelessWidget {
  const _LiveMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}

/// Atribución de OpenStreetMap (requerida por su licencia).
class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) {
    if (!MapConfig.tilesEnabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '© OpenStreetMap',
            style: TextStyle(fontSize: 9, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

/// Pequeño indicador "EN VIVO" con punto pulsante. Reutilizable.
class LivePulseDot extends StatelessWidget {
  const LivePulseDot({super.key, required this.t, this.color = Colors.red});

  /// Valor 0..1 que controla el pulso (normalmente de un AnimationController).
  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 6 + pulse * 8,
            height: 6 + pulse * 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25 * (1 - pulse)),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}
