/// Usuario autenticado (dueño).
class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.plan = 'FREE',
  });

  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final String plan; // FREE | PRO

  bool get isPro => plan == 'PRO';

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String?,
    name: json['name'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    plan: (json['plan'] as String?) ?? 'FREE',
  );
}

/// Sesión: tokens + usuario, tal como responde la API de auth.
class AuthSessionData {
  const AuthSessionData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory AuthSessionData.fromJson(Map<String, dynamic> json) =>
      AuthSessionData(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}
