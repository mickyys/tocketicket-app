import 'package:logger/logger.dart';
import '../services/crashlytics_service.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void init() {
    // Logger inicializado automáticamente
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null || stackTrace != null) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.d(message);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null || stackTrace != null) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(message);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null || stackTrace != null) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.w(message);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Enviar errores a Crashlytics
    if (error != null) {
      CrashlyticsService.recordError(error, stackTrace, reason: message);
    }
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Enviar errores fatales a Crashlytics
    if (error != null) {
      CrashlyticsService.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: true,
      );
    }
  }
}
