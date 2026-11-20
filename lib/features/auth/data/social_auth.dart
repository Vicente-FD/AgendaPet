import 'package:agenda_pet/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Error legible cuando el login social no se puede completar.
class SocialAuthException implements Exception {
  const SocialAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Obtiene los tokens de Google y Apple que el backend sabe verificar.
///
/// Los identificadores de cliente se entregan al compilar, por ejemplo:
///   --dart-define=GOOGLE_SERVER_CLIENT_ID=123-abc.apps.googleusercontent.com
abstract final class SocialAuth {
  static bool _googleListo = false;

  static bool get googleConfigurado =>
      AppConfig.googleServerClientId.isNotEmpty ||
      AppConfig.googleIosClientId.isNotEmpty;

  /// Sign in with Apple solo existe en iOS y macOS. Se consulta con
  /// `defaultTargetPlatform` y no con `dart:io`, que no compila en web.
  static bool get appleDisponible =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Devuelve el `idToken` de Google para `POST /auth/google`.
  static Future<String> googleIdToken() async {
    if (!googleConfigurado) {
      throw const SocialAuthException(
        'El inicio de sesión con Google todavía no está configurado. '
        'Usa tu correo y contraseña.',
      );
    }
    try {
      if (!_googleListo) {
        await GoogleSignIn.instance.initialize(
          clientId: AppConfig.googleIosClientId.isEmpty
              ? null
              : AppConfig.googleIosClientId,
          serverClientId: AppConfig.googleServerClientId.isEmpty
              ? null
              : AppConfig.googleServerClientId,
        );
        _googleListo = true;
      }
      final cuenta = await GoogleSignIn.instance.authenticate();
      final idToken = cuenta.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const SocialAuthException(
          'Google no entregó el token de identidad. Inténtalo de nuevo.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthException('Cancelaste el inicio de sesión.');
      }
      throw SocialAuthException('No se pudo entrar con Google: ${e.code.name}');
    }
  }

  /// Devuelve el `identityToken` y el nombre para `POST /auth/apple`.
  static Future<({String identityToken, String? name})>
  appleCredentials() async {
    if (!appleDisponible) {
      throw const SocialAuthException(
        'Iniciar sesión con Apple solo está disponible en iPhone y Mac.',
      );
    }
    try {
      final credencial = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final token = credencial.identityToken;
      if (token == null || token.isEmpty) {
        throw const SocialAuthException(
          'Apple no entregó el token de identidad. Inténtalo de nuevo.',
        );
      }
      final nombre = [
        credencial.givenName,
        credencial.familyName,
      ].whereType<String>().join(' ').trim();
      return (identityToken: token, name: nombre.isEmpty ? null : nombre);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthException('Cancelaste el inicio de sesión.');
      }
      throw SocialAuthException('No se pudo entrar con Apple: ${e.message}');
    }
  }
}
