import 'package:agenda_pet/core/api/api_client.dart';
import 'package:agenda_pet/core/state/auth_session.dart';
import 'package:agenda_pet/features/auth/data/auth_models.dart';
import 'package:dio/dio.dart';

/// Operaciones sobre la cuenta del usuario.
abstract interface class AccountRepository {
  /// Elimina la cuenta y todos sus datos.
  /// Requisito de App Store (5.1.1(v)) y de Google Play.
  Future<void> deleteAccount();

  /// Cambia el nombre que se muestra en la app.
  Future<AuthUser> updateName(String name);
}

class MockAccountRepository implements AccountRepository {
  @override
  Future<AuthUser> updateName(String name) async {
    final actual = AuthSession.instance.user;
    final actualizado = AuthUser(
      id: actual?.id ?? 'mock-user',
      email: actual?.email,
      name: name,
      avatarUrl: actual?.avatarUrl,
      plan: actual?.plan ?? 'FREE',
    );
    AuthSession.instance.updateUser(actualizado);
    return actualizado;
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    AuthSession.instance.clear();
  }
}

class ApiAccountRepository implements AccountRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<AuthUser> updateName(String name) async {
    final res = await _dio.patch('/users/me', data: {'name': name});
    final actualizado = AuthUser.fromJson(
      res.data['user'] as Map<String, dynamic>,
    );
    AuthSession.instance.updateUser(actualizado);
    return actualizado;
  }

  @override
  Future<void> deleteAccount() async {
    await _dio.delete('/users/me');
    AuthSession.instance.clear();
  }
}
