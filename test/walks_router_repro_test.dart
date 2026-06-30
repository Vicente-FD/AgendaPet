// Reproduce el fallo usando el ROUTER real (transiciones + DevRouteMenu +
// listas con KeepAlive), no una pantalla aislada. Recorre el mouse y hace
// scroll en varios tamaños de ventana, incluido uno bajo (consola abierta).
import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:agenda_pet/features/walks/presentation/live_walk_screen.dart';
import 'package:agenda_pet/features/walks/presentation/walks_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _sizes = [
  Size(1280, 800), // desktop ancho
  Size(900, 380), // ventana baja (consola abierta)
  Size(390, 844), // móvil
];

Future<void> _sweep(WidgetTester tester, TestGesture mouse, Size size) async {
  for (final f in [0.15, 0.35, 0.55, 0.75, 0.9]) {
    await mouse.moveTo(Offset(size.width / 2, size.height * f));
    await tester.pump();
  }
}

void main() {
  for (final size in _sizes) {
    testWidgets('router → /paseos: hover + scroll @ $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: appRouter),
      );
      appRouter.go(AppRoutes.walks);
      await tester.pumpAndSettle();
      expect(find.byType(WalksScreen), findsOneWidget);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset(size.width / 2, 10));
      addTearDown(mouse.removePointer);

      await _sweep(tester, mouse, size);
      await tester.drag(find.byType(WalksScreen), const Offset(0, -260));
      await tester.pump();
      await _sweep(tester, mouse, size);

      expect(tester.takeException(), isNull, reason: 'paseos @ $size');

      appRouter.go(AppRoutes.onboarding);
      await tester.pumpAndSettle();
    });

    testWidgets('router → /paseo-activo: hover @ $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: appRouter),
      );
      appRouter.go(AppRoutes.liveWalk);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LiveWalkScreen), findsOneWidget);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset(size.width / 2, 10));
      addTearDown(mouse.removePointer);

      await _sweep(tester, mouse, size);
      await tester.pump(const Duration(seconds: 1));
      await _sweep(tester, mouse, size);

      expect(tester.takeException(), isNull, reason: 'live @ $size');

      appRouter.go(AppRoutes.onboarding);
      await tester.pumpAndSettle();
    });
  }
}
