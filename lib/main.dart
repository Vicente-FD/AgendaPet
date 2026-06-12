import 'package:agenda_pet/core/routing/app_router.dart';
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(const AgendaPetApp());
}

class AgendaPetApp extends StatelessWidget {
  const AgendaPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agenda Pet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
