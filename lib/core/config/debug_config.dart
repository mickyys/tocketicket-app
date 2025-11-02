/// Configuración de debug para facilitar el desarrollo y testing
class DebugConfig {
  // Credenciales por defecto para debug
  static const String debugEmail = 'hamp.martinez@yopmail.com';
  static const String debugPassword = '12345678';

  // Configuración de debug
  static const bool enableDebugMode = true; // Cambiar a false en producción
  static const bool enableDebugLogs = true;
  static const bool autoLoginOnTokenExpired = true;

  // Configuración de red
  static const int defaultPageSize = 50;
  static const int attendeesPageSize = 100;
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Imprime un log de debug si los logs están habilitados
  static void debugLog(String message) {
    if (enableDebugLogs) {
      print('🐛 DEBUG: $message');
    }
  }

  /// Imprime un log de error
  static void errorLog(String message) {
    print('❌ ERROR: $message');
  }

  /// Imprime un log de éxito
  static void successLog(String message) {
    if (enableDebugLogs) {
      print('✅ SUCCESS: $message');
    }
  }
}
