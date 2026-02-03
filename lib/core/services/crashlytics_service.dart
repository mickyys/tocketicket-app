// Temporalmente comentado para desarrollo sin Firebase
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  // static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Inicializa Crashlytics - Temporalmente deshabilitado
  static Future<void> initialize() async {
    // En modo debug, podemos deshabilitar crashlytics
    // await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    if (kDebugMode) {
      print('CrashlyticsService: Temporalmente deshabilitado para desarrollo');
    }
  }

  /// Registra un error fatal - Temporalmente deshabilitado
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      print('CrashlyticsService.recordError: $exception');
      print('StackTrace: $stackTrace');
      print('Reason: $reason');
      print('Fatal: $fatal');
    }
  }

  /// Registra errores de Flutter - Temporalmente deshabilitado
  static Future<void> recordFlutterError(dynamic errorDetails) async {
    if (kDebugMode) {
      print('CrashlyticsService.recordFlutterError: $errorDetails');
    }
  }

  /// Establece el ID del usuario - Temporalmente deshabilitado
  static Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      print('CrashlyticsService.setUserId: $userId');
    }
  }

  /// Establece una clave personalizada - Temporalmente deshabilitado
  static Future<void> setCustomKey(String key, Object value) async {
    if (kDebugMode) {
      print('CrashlyticsService.setCustomKey: $key = $value');
    }
  }

  /// Registra un mensaje de log - Temporalmente deshabilitado
  static Future<void> log(String message) async {
    if (kDebugMode) {
      print('CrashlyticsService.log: $message');
    }
  }

  /// Establece información del usuario - Temporalmente deshabilitado
  static Future<void> setUserInfo({
    String? id,
    String? userId,
    String? email,
    String? name,
  }) async {
    if (kDebugMode) {
      print(
        'CrashlyticsService.setUserInfo - id: $id, userId: $userId, email: $email, name: $name',
      );
    }
  }

  /// Registra un evento personalizado - Temporalmente deshabilitado
  static Future<void> recordCustomEvent(
    String eventName,
    Map<String, Object>? parameters,
  ) async {
    if (kDebugMode) {
      print(
        'CrashlyticsService.recordCustomEvent: $eventName with parameters: $parameters',
      );
    }
  }

  /// Fuerza un crash para testing - Temporalmente deshabilitado
  static void testCrash() {
    if (kDebugMode) {
      print('CrashlyticsService.testCrash: Crash simulation (disabled)');
    }
  }
}
