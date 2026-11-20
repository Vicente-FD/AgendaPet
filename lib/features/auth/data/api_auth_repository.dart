import 'package:agenda_pet/core/api/api_client.dart';
import 'package:agenda_pet/core/state/auth_session.dart';
import 'package:agenda_pet/features/auth/data/auth_models.dart';
import 'package:agenda_pet/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';

/// Implementación real contra el backend (`backend/`).
class ApiAuthRepository implements AuthRepository {
  final Dio _dio = ApiClient.instance.dio;

  // Las rutas de auth no llevan token (extra noAuth).
  static final Options _noAuth = Options(extra: {'noAuth': true});

  Future<AuthUser> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(path, data: body, options: _noAuth);
      final session = AuthSessionData.fromJson(
        res.data as Map<String, dynamic>,
      );
      AuthSession.instance.setSession(session);
      return session.user;
    } on DioException catch (e) {
      throw AuthException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      return (data['error']['message'] as String?) ?? 'Error de autenticación';
    }
    return 'No se pudo conectar con el servidor';
  }

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      _post('/auth/login', {'email': email, 'password': password});

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) => _post('/auth/register', {
    'email': email,
    'password': password,
    'name': ?name,
  });

  @override
  Future<AuthUser> loginWithGoogle(String idToken) =>
      _post('/auth/google', {'idToken': idToken});

  @override
  Future<AuthUser> loginWithApple(String identityToken, {String? name}) =>
      _post('/auth/apple', {'identityToken': identityToken, 'name': ?name});

  @override
  Future<void> logout() async {
    final refreshToken = AuthSession.instance.refreshToken;
    if (refreshToken != null) {
      try {
        await _dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          options: _noAuth,
        );
      } catch (_) {
        // Ignora errores de red al cerrar sesión.
      }
    }
    AuthSession.instance.clear();
  }
}
