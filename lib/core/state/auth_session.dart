import 'dart:convert';

import 'package:agenda_pet/features/auth/data/auth_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Estado de sesión: tokens y usuario actual.
///
/// Se guarda cifrado en el dispositivo (Keychain en iOS, EncryptedSharedPrefs
/// en Android), así que la sesión sobrevive al cerrar la app.
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  // La versión 11 cifra por defecto en Android (DataStore) y usa el Keychain
  // en iOS, así que no hace falta configurar nada.
  static const _storage = FlutterSecureStorage();
  static const _clave = 'agendapet.session';

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _user;
  bool _restaurada = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AuthUser? get user => _user;
  bool get isAuthenticated => _accessToken != null;

  /// Si ya se intentó leer la sesión guardada. El arranque espera esto para
  /// no mandar al login a alguien que sí tenía sesión.
  bool get restaurada => _restaurada;

  /// Lee la sesión guardada en el dispositivo. Se llama una vez al arrancar.
  Future<void> restore() async {
    if (_restaurada) return;
    try {
      final guardado = await _storage.read(key: _clave);
      if (guardado != null) {
        final json = jsonDecode(guardado) as Map<String, dynamic>;
        _accessToken = json['accessToken'] as String?;
        _refreshToken = json['refreshToken'] as String?;
        final user = json['user'];
        if (user is Map<String, dynamic>) {
          _user = AuthUser.fromJson(user);
        }
      }
    } catch (e) {
      // Si el almacenamiento falla (p. ej. en web sin soporte), se sigue sin
      // sesión en vez de dejar la app trabada.
      debugPrint('No se pudo restaurar la sesión: $e');
    } finally {
      _restaurada = true;
      notifyListeners();
    }
  }

  Future<void> _persistir() async {
    try {
      if (_accessToken == null) {
        await _storage.delete(key: _clave);
        return;
      }
      await _storage.write(
        key: _clave,
        value: jsonEncode({
          'accessToken': _accessToken,
          'refreshToken': _refreshToken,
          'user': _user == null
              ? null
              : {
                  'id': _user!.id,
                  'email': _user!.email,
                  'name': _user!.name,
                  'avatarUrl': _user!.avatarUrl,
                  'plan': _user!.plan,
                },
        }),
      );
    } catch (e) {
      debugPrint('No se pudo guardar la sesión: $e');
    }
  }

  void setSession(AuthSessionData data) {
    _accessToken = data.accessToken;
    _refreshToken = data.refreshToken;
    _user = data.user;
    _restaurada = true;
    notifyListeners();
    _persistir();
  }

  void updateTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
    _persistir();
  }

  /// Actualiza los datos del usuario sin tocar los tokens.
  void updateUser(AuthUser user) {
    _user = user;
    notifyListeners();
    _persistir();
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _restaurada = true;
    notifyListeners();
    _persistir();
  }
}
