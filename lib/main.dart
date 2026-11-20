// Aquí arranca la app.
// Autores: Vicente FD, Mauro Castro Lazcano
// En web las rutas se ven limpias, por ejemplo /onboarding.
import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/notifications/local_notifications.dart';
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/state/auth_session.dart';
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  // Recupera la sesión guardada antes de pintar, para no mandar al login a
  // alguien que ya había iniciado sesión.
  await AuthSession.instance.restore();
  await LocalNotifications.init();
  runApp(const AgendaPetApp());
}

class AgendaPetApp extends StatelessWidget {
  const AgendaPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Agenda Pet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: AppSettings.instance.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
