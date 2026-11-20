import 'package:agenda_pet/core/config/app_config.dart';
import 'package:agenda_pet/core/state/auth_session.dart';
import 'package:dio/dio.dart';

/// Cliente HTTP (Dio) hacia la API. Inyecta el access token y, ante un 401,
/// intenta refrescar la sesión una vez y reintenta la petición.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthSession.instance.accessToken;
          if (token != null && options.extra['noAuth'] != true) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final is401 = e.response?.statusCode == 401;
          final retried = e.requestOptions.extra['retried'] == true;
          if (is401 && !retried && AuthSession.instance.refreshToken != null) {
            if (await _refresh()) {
              final req = e.requestOptions;
              req.extra['retried'] = true;
              req.headers['Authorization'] =
                  'Bearer ${AuthSession.instance.accessToken}';
              try {
                return handler.resolve(await _dio.fetch(req));
              } catch (_) {
                // cae al next()
              }
            } else {
              AuthSession.instance.clear();
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;
  Dio get dio => _dio;

  bool _refreshing = false;

  Future<bool> _refresh() async {
    final refreshToken = AuthSession.instance.refreshToken;
    if (refreshToken == null || _refreshing) return false;
    _refreshing = true;
    try {
      final res = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = res.data as Map<String, dynamic>;
      AuthSession.instance.updateTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }
}
