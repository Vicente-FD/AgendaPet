import 'package:flutter/material.dart';

/// Colores de la app. Todos los widgets usan estos valores.
abstract final class AppColors {
  static const Color primary = Color(0xFF43A047);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFF5F5F5);

  static const Color actionCalendar = Color(0xFF1E88E5);
  static const Color actionVaccines = Color(0xFF43A047);
  static const Color actionMedicines = Color(0xFF8E24AA);
  static const Color actionServices = Color(0xFFF4511E);

  // Funciones nuevas (Fase 2).
  static const Color growth = Color(0xFF00897B); // Historial de crecimiento (teal)
  static const Color memories = Color(0xFFEC407A); // Eventos significativos (rosa)
  static const Color family = Color(0xFF5E35B1); // Familia compartida (morado)
  static const Color tips = Color(0xFFFFB300); // Tips inteligentes (ámbar)
  static const Color feeding = Color(0xFFFB8C00); // Alimentación (naranja cálido)
  static const Color walk = Color(0xFF3D5AFE); // Paseos / GPS (índigo vibrante)
  static const Color walkAccent = Color(0xFF00B0FF); // Acento de degradado paseos

  static const Color textSecondary = Color(0xFF757575);
  static const Color scaffoldBackground = Color(0xFFF8F9FA);

  // Superficies para modo oscuro (ver [AppSurfaces] en app_surfaces.dart).
  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceMuted = Color(0xFF2A2A2A);
}
