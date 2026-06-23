import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/session/app_session.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.homeRoute = AppRoutes.dashboardActive,
    this.navigationShell,
  });

  final int currentIndex;
  final String homeRoute;
  final StatefulNavigationShell? navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (navigationShell != null) {
      if (index == 0 && homeRoute == AppRoutes.dashboardEmpty) {
        context.go(AppRoutes.dashboardEmpty);
        return;
      }
      navigationShell!.goBranch(index);
      return;
    }

    AppSession.homeRoute = homeRoute;

    switch (index) {
      case 0:
        context.go(homeRoute);
      case 1:
        context.go(AppRoutes.agenda);
      case 2:
        context.go(AppRoutes.petProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.primary),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
          label: 'Agenda',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Perfil',
        ),
      ],
    );
  }
}
