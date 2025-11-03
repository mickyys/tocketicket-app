enum Environment { dev, prod }

class AppConfig {
  static Environment _environment = Environment.dev;
  static Environment get environment => _environment;

  static const String _envString = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  static void setEnvironment() {
    switch (_envString.toLowerCase()) {
      case 'prod':
      case 'production':
        _environment = Environment.prod;
        break;
      case 'dev':
      case 'development':
      default:
        _environment = Environment.dev;
        break;
    }
  }

  // URLs base según el entorno
  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://api-dev.tocketicket.cl';
      case Environment.prod:
        return 'https://api.tocketicket.cl';
    }
  }

  // Configuraciones específicas por entorno
  static bool get isDebug => _environment == Environment.dev;
  static bool get enableLogging => _environment == Environment.dev;
  static bool get enableAnalytics => _environment == Environment.prod;

  // Configuración de la aplicación
  static String get appName {
    switch (_environment) {
      case Environment.dev:
        return 'Staff Scanner Dev';
      case Environment.prod:
        return 'Staff Scanner';
    }
  }

  static String get packageName {
    switch (_environment) {
      case Environment.dev:
        return 'cl.tocketicket.staffscanner.dev';
      case Environment.prod:
        return 'cl.tocketicket.staffscanner';
    }
  }

  // Configuración de logging
  static Map<String, dynamic> get loggerConfig {
    return {
      'level': _environment == Environment.dev ? 'debug' : 'info',
      'enableConsole': _environment == Environment.dev,
      'enableFile': true,
    };
  }

  // Timeouts de red
  static Duration get connectionTimeout {
    switch (_environment) {
      case Environment.dev:
        return const Duration(seconds: 30);
      case Environment.prod:
        return const Duration(seconds: 10);
    }
  }

  static Duration get receiveTimeout {
    switch (_environment) {
      case Environment.dev:
        return const Duration(seconds: 30);
      case Environment.prod:
        return const Duration(seconds: 15);
    }
  }

  // Configuración de base de datos
  static String get databaseName {
    switch (_environment) {
      case Environment.dev:
        return 'staffscanner_dev.db';
      case Environment.prod:
        return 'staffscanner.db';
    }
  }

  // Información del entorno para debugging
  static Map<String, dynamic> get environmentInfo {
    return {
      'environment': _environment.name,
      'baseUrl': baseUrl,
      'isDebug': isDebug,
      'appName': appName,
      'packageName': packageName,
      'databaseName': databaseName,
    };
  }

  // Método para imprimir configuración (solo en desarrollo)
  static void printConfig() {
    if (_environment == Environment.dev) {
      print('=== APP CONFIGURATION ===');
      print('Environment: ${_environment.name}');
      print('Base URL: $baseUrl');
      print('App Name: $appName');
      print('Package Name: $packageName');
      print('Debug Mode: $isDebug');
      print('Logging Enabled: $enableLogging');
      print('Analytics Enabled: $enableAnalytics');
      print('Database Name: $databaseName');
      print('========================');
    }
  }
}

  // Test build triggered at: 2025-11-02 22:35:59
