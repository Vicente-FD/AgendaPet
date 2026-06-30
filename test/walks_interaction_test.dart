// Reproduce el crash reportado ("Cannot hit test a render box with no size")
// que ocurría con la ventana baja (consola abierta) + scroll/toque sobre el
// mapa de paseos. Forzamos una superficie BAJA a propósito.
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:agenda_pet/features/walks/presentation/live_walk_screen.dart';
import 'package:agenda_pet/features/walks/presentation/walk_detail_screen.dart';
import 'package:agenda_pet/features/walks/presentation/walks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  testWidgets('LiveWalk: viewport bajo, hover+scroll sin excepción',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const LiveWalkScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Simula el mouse moviéndose sobre el mapa (lo que disparaba mouse_tracker).
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(195, 100));
    addTearDown(mouse.removePointer);
    await tester.pump();
    await mouse.moveTo(const Offset(195, 180));
    await tester.pump();
    await mouse.moveTo(const Offset(120, 120));
    await tester.pump();

    // Scroll dentro de la vista.
    await tester.drag(find.byType(SingleChildScrollView).first,
        const Offset(0, -150));
    await tester.pump();

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('Walks feed: viewport bajo, scroll + hover sin excepción',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const WalksScreen()));
    await tester.pumpAndSettle();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(195, 200));
    addTearDown(mouse.removePointer);
    await tester.pump();

    await tester.fling(find.byType(ListView).first, const Offset(0, -400), 1200);
    await tester.pump(const Duration(milliseconds: 400));
    await mouse.moveTo(const Offset(195, 150));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Walk detail: viewport bajo, scroll sin excepción',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const WalkDetailScreen()));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(ListView).first, const Offset(0, -400), 1200);
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });
}
