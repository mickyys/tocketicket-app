class AppConstants {
  // App Information
  static const String appName = 'Tocke Validator';
  static const String appVersion = '1.0.0';

  // API Configuration
  // IMPORTANTES: Endpoints para desarrollo local según plataforma:
  //
  // 🖥️  Web/macOS: http://localhost:8000
  // 🤖 Android Emulator: http://10.0.2.2:8000
  // 📱 iOS Simulator/Dispositivos físicos: http://[TU_IP_LOCAL]:8000
  //
  // Para encontrar tu IP local, ejecuta en terminal: ifconfig | grep "inet "

  static const String _localNetworkUrl =
      'http://192.168.1.193:8080'; // Tu IP local actual para iOS y dispositivos físicos
  static const String _productionUrl = 'https://api.tocketicket.com';

  // URL base actual - configurada para iOS y dispositivos físicos
  static const String baseUrl = _localNetworkUrl;

  static const String apiVersion = '';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Método helper para obtener la URL según la plataforma (opcional)
  static String getBaseUrlForPlatform() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      return _productionUrl;
    } else {
      // En desarrollo, usa _localNetworkUrl para iOS y dispositivos físicos
      // o _androidEmulatorUrl para emulador Android
      return baseUrl;
    }
  } // Authentication Endpoints

  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String loginOtpEndpoint = '/login-otp';
  static const String requestOtpEndpoint = '/request-otp';
  static const String forgotPasswordEndpoint = '/forgot-password';
  static const String resetPasswordEndpoint = '/reset-password';
  static const String googleLoginEndpoint = '/auth/google/verify-token';

  // Events Endpoints
  static const String eventsEndpoint = '/events';
  static const String organizerEventsEndpoint = '/organizer/events';
  static const String publicEventEndpoint = '/public/events';

  // Validation Endpoints
  static const String validateTicketEndpoint = '/tickets/validate-qr';
  static const String ticketStatusEndpoint = '/tickets/status';

  // Orders Endpoints
  static const String ordersEndpoint = '/orders';
  static const String ordersByEventEndpoint =
      '/organizer/events/{eventId}/orders';
  static const String orderByIdEndpoint = '/organizer/orders';

  // Sync Endpoints (custom for mobile app)
  static const String syncOrdersEndpoint = '/organizer/events/{eventId}/orders';
  static const String syncTicketsEndpoint =
      '/events/{eventId}/tickets'; // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String lastSyncKey = 'last_sync';
  static const String selectedEventKey = 'selected_event';
  static const String themeKey = 'theme_mode';
  static const String soundEnabledKey = 'sound_enabled';
  static const String vibrationEnabledKey = 'vibration_enabled';

  // Database
  static const String databaseName = 'tocket_validator.db';
  static const int databaseVersion = 1;

  // QR Scanner
  static const Duration scanCooldown = Duration(seconds: 2);
  static const String scanSuccessSound = 'assets/sounds/success.mp3';
  static const String scanErrorSound = 'assets/sounds/error.mp3';

  // Validation States
  static const String validationStateValid = 'valid';
  static const String validationStateInvalid = 'invalid';
  static const String validationStateUsed = 'used';
  static const String validationStateExpired = 'expired';

  // Sync
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);

  // UI
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double margin = 8.0;

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}
