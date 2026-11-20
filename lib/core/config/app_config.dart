import 'package:flutter/foundation.dart';

/// Configuración de entorno de la app.
///
/// Por defecto la app funciona con **datos mock** (sin backend). Para usar el
/// backend real levántalo (`backend/`) y corre la app con:
///
///   flutter run --dart-define=USE_BACKEND=true \
///     --dart-define=API_BASE_URL=http://localhost:4000/api
abstract final class AppConfig {
  /// Si es true, los repositorios usan la API real en vez de los mocks.
  static const bool useBackend =
      bool.fromEnvironment('USE_BACKEND', defaultValue: false);

  /// Muestra las funciones que todavía usan datos de ejemplo (paseos,
  /// familia, certificados, crecimiento, eventos, PRO y notificaciones).
  ///
  /// En la v1.0 publicada van ocultas: las tiendas rechazan pantallas de
  /// demostración. Siguen visibles al desarrollar, y se pueden forzar con
  /// `--dart-define=PREVIEW_FEATURES=true`.
  static const bool mostrarEnDesarrollo = bool.fromEnvironment(
    'PREVIEW_FEATURES',
    defaultValue: kDebugMode,
  );

  /// Client ID de OAuth con el que el backend verifica el token de Google.
  /// Es el client ID **web** del proyecto de Google Cloud.
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// Client ID de iOS, necesario solo en iPhone y Mac.
  static const String googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  /// URL base de la API (incluye el prefijo /api).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );
}
