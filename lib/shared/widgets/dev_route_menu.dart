import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Botón de prueba. Solo aparece en modo debug para ir a cualquier pantalla.
class DevRouteMenu extends StatelessWidget {
  const DevRouteMenu({super.key, required this.child});

  final Widget child;

  static const List<({String label, String path})> _routes = [
    (label: 'Bienvenida', path: AppRoutes.onboarding),
    (label: 'Home (María)', path: AppRoutes.dashboardActive),
    (label: 'Home vacío (Ernesto)', path: AppRoutes.dashboardEmpty),
    (label: 'Perfil (Carolina)', path: AppRoutes.petProfile),
    (label: 'Agenda', path: AppRoutes.agenda),
    (label: 'Vacunas', path: AppRoutes.vaccines),
    (label: 'Medicinas', path: AppRoutes.medicines),
    (label: 'Servicios', path: AppRoutes.services),
    (label: 'Agregar cita', path: AppRoutes.addAppointment),
    (label: 'Registrar vacuna', path: AppRoutes.addVaccine),
    (label: 'Agregar medicina', path: AppRoutes.addMedicine),
    (label: 'Agregar servicio', path: AppRoutes.addService),
    (label: 'Agregar mascota', path: AppRoutes.addPet),
    (label: 'Añadir recordatorio', path: AppRoutes.addReminder),
    (label: 'Alimentación', path: AppRoutes.feeding),
    (label: 'Registrar alimento', path: AppRoutes.addFeeding),
    (label: 'Paseos (feed)', path: AppRoutes.walks),
    (label: 'Paseo en vivo', path: AppRoutes.liveWalk),
    (label: 'Detalle de paseo', path: AppRoutes.walkDetail),
    (label: 'Historial crecimiento', path: AppRoutes.growth),
    (label: 'Eventos significativos', path: AppRoutes.events),
    (label: 'Tips', path: AppRoutes.tips),
    (label: 'Familia compartida', path: AppRoutes.family),
    (label: 'Notificaciones', path: AppRoutes.notifications),
    (label: 'Agregar foto crecimiento', path: AppRoutes.addGrowth),
    (label: 'Agregar evento', path: AppRoutes.addEvent),
    (label: 'Login', path: AppRoutes.login),
    (label: 'Registro', path: AppRoutes.register),
    (label: 'Ajustes', path: AppRoutes.settings),
    (label: 'Mi cuenta', path: AppRoutes.userProfile),
    (label: 'Suscripción (PRO)', path: AppRoutes.subscription),
    (label: 'Pago / checkout', path: AppRoutes.checkout),
    (label: 'Suscripción éxito', path: AppRoutes.subscriptionSuccess),
    (label: 'Mis mascotas', path: AppRoutes.pets),
  ];

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return Stack(
      children: [
        child,
        Positioned(
          right: 16,
          bottom: 88,
          child: FloatingActionButton.small(
            heroTag: 'dev-routes',
            backgroundColor: AppColors.primary,
            onPressed: () => _showRouteSheet(context),
            child: const Icon(Icons.route, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showRouteSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final current = GoRouterState.of(context).uri.path;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vista previa de rutas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ruta actual: $current',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              ..._routes.map(
                (route) => ListTile(
                  leading: Icon(
                    current == route.path
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: AppColors.primary,
                  ),
                  title: Text(route.label),
                  subtitle: Text(route.path),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(route.path);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }
}
