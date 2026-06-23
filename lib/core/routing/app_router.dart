// Rutas de la app. La raíz (/) manda a /onboarding.
import 'package:agenda_pet/features/agenda/presentation/agenda_screen.dart';
import 'package:agenda_pet/features/dashboard_active/presentation/dashboard_active_screen.dart';
import 'package:agenda_pet/features/dashboard_empty/presentation/dashboard_empty_screen.dart';
import 'package:agenda_pet/features/forms/presentation/add_appointment_screen.dart';
import 'package:agenda_pet/features/forms/presentation/add_medicine_screen.dart';
import 'package:agenda_pet/features/forms/presentation/add_pet_screen.dart';
import 'package:agenda_pet/features/forms/presentation/add_reminder_screen.dart';
import 'package:agenda_pet/features/forms/presentation/add_service_screen.dart';
import 'package:agenda_pet/features/forms/presentation/add_vaccine_screen.dart';
import 'package:agenda_pet/features/medicines/presentation/medicines_screen.dart';
import 'package:agenda_pet/features/onboarding/presentation/onboarding_screen.dart';
import 'package:agenda_pet/features/pet_profile/presentation/pet_profile_screen.dart';
import 'package:agenda_pet/features/services/presentation/services_screen.dart';
import 'package:agenda_pet/features/vaccines/presentation/vaccines_screen.dart';
import 'package:agenda_pet/shared/widgets/app_shell.dart';
import 'package:agenda_pet/shared/widgets/dev_route_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String dashboardEmpty = '/dashboard-empty';
  static const String dashboardActive = '/dashboard-active';
  static const String petProfile = '/pet-profile';
  static const String agenda = '/agenda';
  static const String vaccines = '/vacunas';
  static const String medicines = '/medicinas';
  static const String services = '/servicios';
  static const String addAppointment = '/agregar-cita';
  static const String addVaccine = '/agregar-vacuna';
  static const String addMedicine = '/agregar-medicina';
  static const String addService = '/agregar-servicio';
  static const String addPet = '/agregar-mascota';
  static const String addReminder = '/agregar-recordatorio';
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: kDebugMode,
  initialLocation: AppRoutes.onboarding,
  redirect: (context, state) {
    if (state.uri.path == '/') {
      return AppRoutes.onboarding;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, _) => AppRoutes.onboarding,
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboardActive,
              name: 'dashboard-active',
              pageBuilder: (context, state) => _noTransitionPage(
                state: state,
                child: const DashboardActiveScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.agenda,
              name: 'agenda',
              pageBuilder: (context, state) => _noTransitionPage(
                state: state,
                child: const AgendaScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.petProfile,
              name: 'pet-profile',
              pageBuilder: (context, state) => _noTransitionPage(
                state: state,
                child: const PetProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.dashboardEmpty,
      name: 'dashboard-empty',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const DashboardEmptyScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.vaccines,
      name: 'vacunas',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const VaccinesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.medicines,
      name: 'medicinas',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const MedicinesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.services,
      name: 'servicios',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const ServicesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addAppointment,
      name: 'agregar-cita',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const AddAppointmentScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addVaccine,
      name: 'agregar-vacuna',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const AddVaccineScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addMedicine,
      name: 'agregar-medicina',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const AddMedicineScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addService,
      name: 'agregar-servicio',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const AddServiceScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addPet,
      name: 'agregar-mascota',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const AddPetScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addReminder,
      name: 'agregar-recordatorio',
      pageBuilder: (context, state) => _slidePage(
        state: state,
        child: const AddReminderScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no encontrada')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('No existe: ${state.uri.path}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.onboarding),
            child: const Text('Ir a Bienvenida'),
          ),
        ],
      ),
    ),
  ),
);

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: DevRouteMenu(child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: DevRouteMenu(child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1, 0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeOutCubic),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _noTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}
