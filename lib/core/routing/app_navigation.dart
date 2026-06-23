import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/session/app_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension AppNavigation on BuildContext {
  void goOnboarding() => go(AppRoutes.onboarding);

  void goDashboardActive() {
    AppSession.homeRoute = AppRoutes.dashboardActive;
    go(AppRoutes.dashboardActive);
  }

  void goDashboardEmpty() {
    AppSession.homeRoute = AppRoutes.dashboardEmpty;
    go(AppRoutes.dashboardEmpty);
  }

  void goPetProfile() => go(AppRoutes.petProfile);

  void goAgenda() => go(AppRoutes.agenda);

  void goVaccines() => push(AppRoutes.vaccines);

  void goMedicines() => push(AppRoutes.medicines);

  void goServices() => push(AppRoutes.services);

  void goAddAppointment() => push(AppRoutes.addAppointment);

  void goAddVaccine() => push(AppRoutes.addVaccine);

  void goAddMedicine() => push(AppRoutes.addMedicine);

  void goAddService() => push(AppRoutes.addService);

  void goAddPet() => push(AppRoutes.addPet);

  void goAddReminder() => push(AppRoutes.addReminder);
}
