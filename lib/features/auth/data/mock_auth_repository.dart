import 'package:agenda_pet/core/state/auth_session.dart';
import 'package:agenda_pet/features/auth/data/auth_models.dart';
import 'package:agenda_pet/features/auth/data/auth_repository.dart';

/// Implementación mock: acepta cualquier credencial y crea una sesión falsa.
/// Es la que usa la app por defecto (sin backend).
class MockAuthRepository implements AuthRepository {
  Future<AuthUser> _fakeSession({String? email, String? name}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final user = AuthUser(
      id: 'mock-user',
      email: email ?? 'maria@agendapet.cl',
      name: name ?? 'María',
      plan: 'FREE',
    );
    AuthSession.instance.setSession(
      AuthSessionData(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        user: user,
      ),
    );
    return user;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      _fakeSession(email: email);

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) => _fakeSession(email: email, name: name);

  @override
  Future<AuthUser> loginWithGoogle(String idToken) =>
      _fakeSession(name: 'María');

  @override
  Future<AuthUser> loginWithApple(String identityToken, {String? name}) =>
      _fakeSession(name: name ?? 'María');

  @override
  Future<void> logout() async => AuthSession.instance.clear();
}
