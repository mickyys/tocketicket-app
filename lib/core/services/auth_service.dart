import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/http_header_utils.dart';
import '../utils/logger.dart';
import '../../config/app_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static http.Client? _httpClient;
  static final _sessionController = StreamController<bool>.broadcast();
  static Stream<bool> get onSessionChange => _sessionController.stream;

  // Método para configurar el cliente HTTP (se llamará desde DI)
  static void setHttpClient(http.Client client) {
    _httpClient = client;
    AppLogger.debug('🔧 HTTP: AuthService configurado con cliente HTTP');
  }

  // Getter para obtener el cliente HTTP
  static http.Client get _client {
    if (_httpClient == null) {
      // Auto-configurar con cliente HTTP básico si no está configurado
      AppLogger.debug(
        '🔧 HTTP: Auto-configurando AuthService con cliente HTTP básico',
      );
      _httpClient = http.Client();
    }
    return _httpClient!;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Intentando login para: $email');
      AppLogger.debug('URL de login: ${AppConstants.loginEndpoint}');

      final response = await _client
          .post(
            Uri.parse(AppConstants.loginEndpoint),
            headers: HttpHeaderUtils.baseHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = jsonDecode(response.body);
      AppLogger.info('Respuesta del servidor recibida', {
        'status_code': response.statusCode,
        'has_token': responseData['token'] != null,
        'has_user': responseData['user'] != null,
      });

      if (response.statusCode == 200) {
        AppLogger.info('Login exitoso para: $email');

        // Guardar tokens de forma segura
        if (responseData['token'] != null) {
          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: responseData['token'],
          );
        }

        if (responseData['refresh_token'] != null) {
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: responseData['refresh_token'],
          );
        }

        // Guardar información del usuario
        if (responseData['user'] != null) {
          await _storage.write(
            key: AppConstants.userDataKey,
            value: jsonEncode(responseData['user']),
          );
        }

        _sessionController.add(true);

        return {'success': true, 'data': responseData};
      } else {
        AppLogger.error('Error en login: ${response.statusCode}');

        return {
          'success': false,
          'error':
              responseData['message'] ??
              responseData['error'] ??
              'Error al iniciar sesión',
        };
      }
    } catch (e, stackTrace) {
      AppLogger.error('Excepción en login', e, stackTrace);

      return {
        'success': false,
        'error': 'Error de conexión. Verifica tu internet.',
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle({
    required String googleToken,
  }) async {
    try {
      AppLogger.info('Intentando login con Google');
      AppLogger.debug(
        'URL de Google login: ${AppConstants.googleLoginEndpoint}',
      );

      final response = await _client
          .post(
            Uri.parse(AppConstants.googleLoginEndpoint),
            headers: HttpHeaderUtils.baseHeaders,
            body: jsonEncode({'token': googleToken}),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = jsonDecode(response.body);
      AppLogger.info('Respuesta de Google login recibida', {
        'status_code': response.statusCode,
        'has_token': responseData['token'] != null,
        'has_user': responseData['user'] != null,
      });

      if (response.statusCode == 200) {
        AppLogger.info('Google login exitoso');

        // Guardar tokens de forma segura
        if (responseData['token'] != null) {
          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: responseData['token'],
          );
        }

        if (responseData['refresh_token'] != null) {
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: responseData['refresh_token'],
          );
        }

        // Guardar información del usuario
        if (responseData['user'] != null) {
          await _storage.write(
            key: AppConstants.userDataKey,
            value: jsonEncode(responseData['user']),
          );
        }

        return {'success': true, 'data': responseData};
      } else {
        AppLogger.error('Error en Google login: ${response.statusCode}');

        return {
          'success': false,
          'error':
              responseData['message'] ?? 'Error al iniciar sesión con Google',
        };
      }
    } catch (e, stackTrace) {
      AppLogger.error('Excepción en Google login', e, stackTrace);

      return {
        'success': false,
        'error': 'Error de conexión. Verifica tu internet.',
      };
    }
  }

  static Future<void> saveRememberMeCredentials(
    String email,
    String password,
  ) async {
    await _storage.write(key: 'remember_me_email', value: email);
    await _storage.write(key: 'remember_me_password', value: password);
    await _storage.write(key: 'remember_me_enabled', value: 'true');
  }

  static Future<void> clearRememberMeCredentials() async {
    await _storage.delete(key: 'remember_me_email');
    await _storage.delete(key: 'remember_me_password');
    await _storage.write(key: 'remember_me_enabled', value: 'false');
  }

  static Future<Map<String, String?>> getRememberMeCredentials() async {
    final enabled = await _storage.read(key: 'remember_me_enabled');
    if (enabled == 'true') {
      final email = await _storage.read(key: 'remember_me_email');
      final password = await _storage.read(key: 'remember_me_password');
      return {'email': email, 'password': password};
    }
    return {'email': null, 'password': null};
  }

  static Future<Map<String, dynamic>> requestOtp({
    required String email,
  }) async {
    try {
      AppLogger.info('Solicitando código OTP para: $email');
      AppLogger.debug('URL de request OTP: ${AppConstants.requestOtpEndpoint}');

      final response = await _client
          .post(
            Uri.parse(AppConstants.requestOtpEndpoint),
            headers: HttpHeaderUtils.baseHeaders,
            body: jsonEncode({'email': email}),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = jsonDecode(response.body);
      AppLogger.info('Respuesta de request OTP recibida', {
        'status_code': response.statusCode,
        'email': email,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('Código OTP enviado exitosamente a: $email');
        return {'success': true, 'data': responseData};
      } else {
        final errorMessage =
            responseData['error'] ??
            responseData['message'] ??
            'Error al solicitar código OTP';
        AppLogger.warning('Error al solicitar OTP', {
          'status_code': response.statusCode,
          'error': errorMessage,
        });
        return {'success': false, 'error': errorMessage};
      }
    } on http.ClientException catch (e) {
      AppLogger.error('Error de conexión al solicitar OTP', {
        'error': e.toString(),
      });
      return {
        'success': false,
        'error': 'Error de conexión. Por favor verifica tu internet.',
      };
    } catch (e) {
      AppLogger.error('Error inesperado al solicitar OTP', {
        'error': e.toString(),
      });
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> loginWithCode({
    required String code,
    required String email,
  }) async {
    try {
      AppLogger.info('Intentando login con código único');
      AppLogger.debug('URL de login OTP: ${AppConstants.loginOtpEndpoint}');

      final response = await _client
          .post(
            Uri.parse(AppConstants.loginOtpEndpoint),
            headers: HttpHeaderUtils.baseHeaders,
            body: jsonEncode({'otp': code, 'email': email}),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = jsonDecode(response.body);
      AppLogger.info('Respuesta de login con código recibida', {
        'status_code': response.statusCode,
        'has_token': responseData['token'] != null,
        'has_user': responseData['user'] != null,
      });

      if (response.statusCode == 200) {
        AppLogger.info('Login con código exitoso');

        // Guardar tokens de forma segura
        if (responseData['token'] != null) {
          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: responseData['token'],
          );
        }

        if (responseData['refresh_token'] != null) {
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: responseData['refresh_token'],
          );
        }

        // Guardar información del usuario
        if (responseData['user'] != null) {
          await _storage.write(
            key: AppConstants.userDataKey,
            value: jsonEncode(responseData['user']),
          );
        }

        return {'success': true, 'data': responseData};
      } else {
        AppLogger.error('Error en login con código: ${response.statusCode}');

        return {
          'success': false,
          'error': responseData['message'] ?? 'Código inválido',
        };
      }
    } catch (e, stackTrace) {
      AppLogger.error('Excepción en login con código', e, stackTrace);

      return {
        'success': false,
        'error': 'Error de conexión. Verifica tu internet.',
      };
    }
  }

  static Future<void> fetchAndSaveProfile() async {
    try {
      final token = await getAccessToken();
      if (token == null) return;
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}/users/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(AppConstants.connectTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['organizer'] != null) {
          await _storage.write(
            key: AppConstants.organizerProfileKey,
            value: jsonEncode(data['organizer']),
          );
        }
        // Update user data with roles/permissions from profile
        if (data['user'] != null) {
          await _storage.write(
            key: AppConstants.userDataKey,
            value: jsonEncode(data['user']),
          );
        }
        // Save allowed eventIds for viewer role
        final roles = (data['user']?['roles'] as List?)?.cast<String>() ?? [];
        if (roles.contains('viewer') && data['user']?['eventIds'] != null) {
          await _storage.write(
            key: AppConstants.allowedEventIdsKey,
            value: jsonEncode(data['user']?['eventIds']),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error fetching profile: $e');
    }
  }

  static Future<Map<String, dynamic>?> getOrganizerProfile() async {
    try {
      final data = await _storage.read(key: AppConstants.organizerProfileKey);
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      AppLogger.error('Error obteniendo perfil de organizador: $e');
      return null;
    }
  }

  static Future<List<String>> getAllowedEventIds() async {
    try {
      final data = await _storage.read(key: AppConstants.allowedEventIdsKey);
      if (data != null) {
        return (jsonDecode(data) as List).cast<String>();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error obteniendo eventos permitidos: $e');
      return [];
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error verificando login: $e');
      return false;
    }
  }

  static Future<bool> canValidateTicket() async {
    try {
      final data = await getUserData();
      if (data == null) return false;
      final roles = (data['roles'] as List?)?.cast<String>() ?? [];
      // Viewers can only view, not validate tickets
      if (roles.contains('viewer')) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      AppLogger.error('Error obteniendo token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userData = await _storage.read(key: AppConstants.userDataKey);
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error obteniendo datos de usuario: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);
      await _storage.delete(key: AppConstants.organizerProfileKey);
      _sessionController.add(false);
      AppLogger.info('Logout exitoso');
    } catch (e) {
      AppLogger.error('Error en logout: $e');
    }
  }

  static void dispose() {
    _sessionController.close();
  }
}
