import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Persona que puede iniciar paseos: un miembro de la familia o un paseador
/// profesional añadido a la familia.
class Walker {
  const Walker({
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.rating,
    required this.walksDone,
    this.isProfessional = false,
  });

  final String name;

  /// "Familia" o "Paseador".
  final String role;
  final Color avatarColor;
  final double rating;
  final int walksDone;
  final bool isProfessional;
}

/// Un paseo registrado (estilo Strava): recorrido real + métricas.
class WalkRecord {
  const WalkRecord({
    required this.walkerName,
    required this.role,
    required this.petName,
    required this.dateLabel,
    required this.distanceKm,
    required this.durationLabel,
    required this.paceLabel,
    required this.kudos,
    required this.avatarColor,
    required this.route,
    this.byWalker = false,
  });

  final String walkerName;
  final String role;
  final String petName;
  final String dateLabel;
  final double distanceKm;
  final String durationLabel;
  final String paceLabel;
  final int kudos;
  final Color avatarColor;

  /// Recorrido real (coordenadas geográficas) para dibujar en el mapa.
  final List<LatLng> route;

  /// true si lo inició un paseador; false si un familiar.
  final bool byWalker;
}

abstract final class WalksMockData {
  static const String petName = 'Carolina';

  // --- Recorridos de ejemplo (coordenadas reales, Santiago de Chile). ---

  // Parque Forestal / Bellas Artes (Santiago Centro).
  static const List<LatLng> _routeForestal = [
    LatLng(-33.43594, -70.64510),
    LatLng(-33.43520, -70.64300),
    LatLng(-33.43470, -70.64090),
    LatLng(-33.43540, -70.63900),
    LatLng(-33.43680, -70.63820),
    LatLng(-33.43800, -70.63930),
    LatLng(-33.43760, -70.64150),
  ];

  // Providencia (Parque de las Esculturas / Pedro de Valdivia).
  static const List<LatLng> _routeProvidencia = [
    LatLng(-33.42640, -70.61600),
    LatLng(-33.42560, -70.61350),
    LatLng(-33.42600, -70.61100),
    LatLng(-33.42760, -70.61030),
    LatLng(-33.42880, -70.61180),
    LatLng(-33.42820, -70.61450),
  ];

  // Parque Bustamante / Providencia sur (Ñuñoa límite).
  static const List<LatLng> _routeBustamante = [
    LatLng(-33.44560, -70.63230),
    LatLng(-33.44450, -70.63050),
    LatLng(-33.44380, -70.62830),
    LatLng(-33.44500, -70.62680),
    LatLng(-33.44680, -70.62740),
    LatLng(-33.44760, -70.62950),
  ];

  /// Resumen semanal (para la tarjeta destacada).
  static const double weeklyKm = 12.4;
  static const int weeklyWalks = 6;
  static const int weeklyMinutes = 184;

  /// Paseadores disponibles: familia + profesional añadido a la familia.
  static const List<Walker> walkers = [
    Walker(
      name: 'Diego',
      role: 'Paseador',
      avatarColor: AppColors.walk,
      rating: 4.9,
      walksDone: 128,
      isProfessional: true,
    ),
    Walker(
      name: 'María',
      role: 'Familia',
      avatarColor: AppColors.primary,
      rating: 5.0,
      walksDone: 42,
    ),
    Walker(
      name: 'Jorge',
      role: 'Familia',
      avatarColor: AppColors.actionCalendar,
      rating: 4.8,
      walksDone: 17,
    ),
  ];

  /// Historial de paseos, del más reciente al más antiguo.
  static const List<WalkRecord> records = [
    WalkRecord(
      walkerName: 'Diego',
      role: 'Paseador',
      petName: 'Carolina',
      dateLabel: 'Hoy · 09:15',
      distanceKm: 2.6,
      durationLabel: '31 min',
      paceLabel: "11'55\"/km",
      kudos: 12,
      avatarColor: AppColors.walk,
      route: _routeBustamante,
      byWalker: true,
    ),
    WalkRecord(
      walkerName: 'María',
      role: 'Familia',
      petName: 'Carolina',
      dateLabel: 'Ayer · 19:40',
      distanceKm: 1.8,
      durationLabel: '24 min',
      paceLabel: "13'20\"/km",
      kudos: 8,
      avatarColor: AppColors.primary,
      route: _routeForestal,
    ),
    WalkRecord(
      walkerName: 'Diego',
      role: 'Paseador',
      petName: 'Carolina',
      dateLabel: 'Lun · 08:05',
      distanceKm: 3.1,
      durationLabel: '38 min',
      paceLabel: "12'15\"/km",
      kudos: 21,
      avatarColor: AppColors.walk,
      route: _routeProvidencia,
      byWalker: true,
    ),
    WalkRecord(
      walkerName: 'Jorge',
      role: 'Familia',
      petName: 'Carolina',
      dateLabel: 'Dom · 17:20',
      distanceKm: 2.0,
      durationLabel: '27 min',
      paceLabel: "13'30\"/km",
      kudos: 5,
      avatarColor: AppColors.actionCalendar,
      route: _routeForestal,
    ),
  ];

  /// Parciales por kilómetro del paseo destacado (estilo Strava).
  static const List<({String km, String time, double intensity})> splits = [
    (km: 'Km 1', time: "11'40\"", intensity: 0.9),
    (km: 'Km 2', time: "12'05\"", intensity: 0.7),
    (km: 'Km 0.6', time: "07'10\"", intensity: 0.55),
  ];
}
