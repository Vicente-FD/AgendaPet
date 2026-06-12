import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension AppNavigation on BuildContext {
  void goOnboarding() => go(AppRoutes.onboarding);

  void goDashboardActive() => go(AppRoutes.dashboardActive);

  void goDashboardEmpty() => go(AppRoutes.dashboardEmpty);

  void goPetProfile() => push(AppRoutes.petProfile);

  void goAgenda() => push(AppRoutes.agenda);

  void goVaccines() => push(AppRoutes.vaccines);

  void goMedicines() => push(AppRoutes.medicines);

  void goServices() => push(AppRoutes.services);
}
