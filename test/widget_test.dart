import 'package:agenda_pet/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Muestra pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const AgendaPetApp());
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido a Agenda Pet!'), findsOneWidget);
    expect(find.text('¡Comenzar!'), findsOneWidget);
  });
}
