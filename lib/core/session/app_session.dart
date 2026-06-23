import 'package:agenda_pet/core/routing/app_router.dart';

/// Sesión mock de Fase 1: recuerda desde qué home entró el usuario.
abstract final class AppSession {
  static String homeRoute = AppRoutes.dashboardActive;
}
