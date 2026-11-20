import 'package:agenda_pet/core/state/auth_session.dart';
import 'package:agenda_pet/features/auth/data/auth_models.dart';

/// Deja una sesión iniciada para los tests que navegan por el router.
/// Sin esto, el guard de autenticación los manda al login.
void iniciarSesionDePrueba() {
  AuthSession.instance.setSession(
    const AuthSessionData(
      accessToken: 'token-de-prueba',
      refreshToken: 'refresh-de-prueba',
      user: AuthUser(
        id: 'usuario-de-prueba',
        email: 'test@agendapet.cl',
        name: 'Test',
      ),
    ),
  );
}
