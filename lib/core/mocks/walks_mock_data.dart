import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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

/// Un paseo registrado (estilo Strava): recorrido + métricas.
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

  /// Puntos del recorrido normalizados (0..1) para [RouteMap].
  final List<Offset> route;

  /// true si lo inició un paseador; false si un familiar.
  final bool byWalker;
}

abstract final class WalksMockData {
  static const String petName = 'Carolina';

  // --- Recorridos de ejemplo (coordenadas normalizadas 0..1). ---
  static const List<Offset> _routeA = [
    Offset(0.08, 0.80),
    Offset(0.18, 0.60),
    Offset(0.32, 0.66),
    Offset(0.42, 0.46),
    Offset(0.56, 0.52),
    Offset(0.68, 0.32),
    Offset(0.82, 0.40),
    Offset(0.92, 0.20),
  ];

  static const List<Offset> _routeB = [
    Offset(0.10, 0.28),
    Offset(0.24, 0.40),
    Offset(0.30, 0.62),
    Offset(0.46, 0.68),
    Offset(0.58, 0.50),
    Offset(0.72, 0.58),
    Offset(0.86, 0.42),
    Offset(0.90, 0.72),
  ];

  static const List<Offset> _routeC = [
    Offset(0.10, 0.72),
    Offset(0.22, 0.50),
    Offset(0.36, 0.56),
    Offset(0.46, 0.34),
    Offset(0.62, 0.42),
    Offset(0.74, 0.24),
    Offset(0.90, 0.34),
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
      route: _routeC,
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
      route: _routeA,
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
      route: _routeB,
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
      route: _routeA,
    ),
  ];

  // --- Paseo en vivo (pantalla de seguimiento en tiempo real). ---
  static const List<Offset> liveRoute = _routeC;
  static const String liveWalker = 'Diego';
  static const String liveWalkerRole = 'Paseador';

  /// Objetivos para mapear el progreso de la animación a métricas realistas.
  static const double liveTargetKm = 2.6;
  static const int liveTargetSeconds = 1860; // 31:00

  /// Parciales por kilómetro del paseo destacado (estilo Strava).
  static const List<({String km, String time, double intensity})> splits = [
    (km: 'Km 1', time: "11'40\"", intensity: 0.9),
    (km: 'Km 2', time: "12'05\"", intensity: 0.7),
    (km: 'Km 0.6', time: "07'10\"", intensity: 0.55),
  ];
}
