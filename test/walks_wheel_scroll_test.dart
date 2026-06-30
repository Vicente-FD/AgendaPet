// Reproduce "al bajar con la rueda aparecen errores": el mouse queda QUIETO y
// el contenido se mueve bajo el cursor (PointerScrollEvent). Eso fuerza al
// MouseTracker a re-hacer hit-test sobre lo que va quedando bajo el puntero.
import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _wheelDown(WidgetTester tester, Size size, String route) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: appRouter),
  );
  appRouter.go(route);
  await tester.pumpAndSettle();

  // Mouse quieto cerca del centro-alto, donde va pasando el contenido.
  final pos = Offset(size.width / 2, size.height * 0.4);
  final mouse = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(mouse.hover(pos));
  await tester.pump();

  // Baja con la rueda en muchos pasos, hasta el fondo.
  for (var i = 0; i < 30; i++) {
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
    await tester.pump();
    // Pequeño "temblor" del cursor para forzar re-hit-test como en un mouse real.
    await tester.sendEventToBinding(
        mouse.hover(pos + Offset(0, (i.isEven ? 1 : -1).toDouble())));
    await tester.pump();
  }

  appRouter.go(AppRoutes.onboarding);
  await tester.pumpAndSettle();
}

void main() {
  const sizes = [Size(1280, 800), Size(1280, 620), Size(900, 700)];

  for (final size in sizes) {
    testWidgets('rueda hacia abajo en /paseos @ $size sin excepción',
        (tester) async {
      await _wheelDown(tester, size, AppRoutes.walks);
    });

    testWidgets('rueda hacia abajo en dashboard @ $size sin excepción',
        (tester) async {
      await _wheelDown(tester, size, AppRoutes.dashboardActive);
    });
  }
}
