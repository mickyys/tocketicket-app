import 'dart:io';

/// Utilidades para manejo de headers HTTP comunes
class HttpHeaderUtils {
  /// Obtiene el valor de la plataforma para el header X-Platform
  static String get platformHeader => Platform.isAndroid ? 'android' : 'ios';

  /// Obtiene headers base comunes para todas las peticiones
  static Map<String, String> get baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Platform': platformHeader,
  };

  /// Obtiene headers con autenticación
  static Map<String, String> getAuthHeaders(String token) => {
    ...baseHeaders,
    'Authorization': 'Bearer $token',
  };
}
