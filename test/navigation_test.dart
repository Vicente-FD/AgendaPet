// Verifica que la campana del dashboard abre la pantalla de Notificaciones,
// incluso tocando justo encima de la insignia (esquina superior derecha).
import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:agenda_pet/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La campana abre Notificaciones (tap al centro)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: appRouter),
    );
    appRouter.go(AppRoutes.dashboardActive);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('La campana abre Notificaciones (tap sobre la insignia)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: appRouter),
    );
    appRouter.go(AppRoutes.dashboardActive);
    await tester.pumpAndSettle();

    // Toca la esquina superior derecha del icono, justo donde está la insignia.
    final iconRect = tester.getRect(find.byIcon(Icons.notifications_outlined));
    await tester.tapAt(Offset(iconRect.right - 3, iconRect.top + 3));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
  });
}
