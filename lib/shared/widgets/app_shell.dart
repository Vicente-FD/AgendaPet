import 'package:agenda_pet/core/session/app_session.dart';
import 'package:agenda_pet/shared/widgets/app_bottom_nav.dart';
import 'package:agenda_pet/shared/widgets/dev_route_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return DevRouteMenu(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          homeRoute: AppSession.homeRoute,
          navigationShell: navigationShell,
        ),
      ),
    );
  }
}
