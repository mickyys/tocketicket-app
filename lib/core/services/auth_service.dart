import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/http_header_utils.dart';
import '../utils/logger.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Intentando login para: $email');
      AppLogger.debug('URL de login: ${AppConstants.loginEndpoint}');

      final response = await http
          .post(
            Uri.parse(AppConstants.loginEndpoint),
            headers: HttpHeaderUtils.baseHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = jsonDecode(response.body);
      AppLogger.info('Respuesta del servidor: $responseData');

      if (response.statusCode == 200) {
        AppLogger.info('Login exitoso para: $email');

        AppLogger.info("responseData: $responseData");

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
        AppLogger.error('Error en login: ${response.statusCode}');
        return {
          'success': false,
          'error': responseData['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      AppLogger.error('Excepción en login: $e');
      return {
        'success': false,
        'error': 'Error de conexión. Verifica tu internet.',
      };
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
      AppLogger.info('Logout exitoso');
    } catch (e) {
      AppLogger.error('Error en logout: $e');
    }
  }
}
