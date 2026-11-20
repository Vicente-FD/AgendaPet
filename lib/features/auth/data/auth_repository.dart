import 'package:agenda_pet/features/auth/data/auth_models.dart';

/// Error de autenticación con mensaje presentable al usuario.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Contrato de autenticación. Dos implementaciones: mock y API real.
abstract interface class AuthRepository {
  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  });

  Future<AuthUser> loginWithGoogle(String idToken);

  Future<AuthUser> loginWithApple(String identityToken, {String? name});

  Future<void> logout();
}
