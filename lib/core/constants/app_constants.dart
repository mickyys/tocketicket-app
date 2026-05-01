import 'package:tocke/config/app_config.dart';

class AppConstants {
  // App Information
  static const String appName = 'Tocke Ticket';
  static const String appVersion = '1.0.6';

  // API Configuration
  static const String apiVersion = '';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Authentication Endpoints - Usando AppConfig.baseUrl dinámicamente
  static String get loginEndpoint => '${AppConfig.baseUrl}/login';
  static String get registerEndpoint => '${AppConfig.baseUrl}/register';
  static String get logoutEndpoint => '${AppConfig.baseUrl}/logout';
  static String get loginOtpEndpoint => '${AppConfig.baseUrl}/login-otp';
  static String get requestOtpEndpoint => '${AppConfig.baseUrl}/request-otp';
  static String get forgotPasswordEndpoint =>
      '${AppConfig.baseUrl}/forgot-password';
  static String get resetPasswordEndpoint =>
      '${AppConfig.baseUrl}/reset-password';
  static String get googleLoginEndpoint =>
      '${AppConfig.baseUrl}/auth/google/verify-token';

  // Events Endpoints
  static String get eventsEndpoint => '${AppConfig.baseUrl}/events';
  static String get organizerEventsEndpoint =>
      '${AppConfig.baseUrl}/organizer/events';
  static String get organizerTicketSearchByDocumentEndpoint =>
      '${AppConfig.baseUrl}/organizer/tickets/search-by-document';
  static String get publicEventEndpoint => '${AppConfig.baseUrl}/public/events';

  // Validation Endpoints
  static String get validateTicketEndpoint =>
      '${AppConfig.baseUrl}/tickets/validate-qr';
  static String get ticketStatusEndpoint =>
      '${AppConfig.baseUrl}/tickets/status';

  // Orders Endpoints
  static String get ordersEndpoint => '${AppConfig.baseUrl}/orders';
  static String get ordersByEventEndpoint =>
      '${AppConfig.baseUrl}/organizer/events/{eventId}/orders';
  static String get orderByIdEndpoint =>
      '${AppConfig.baseUrl}/organizer/orders';

  // Sync Endpoints (custom for mobile app)
  static String get syncOrdersEndpoint =>
      '${AppConfig.baseUrl}/organizer/events/{eventId}/orders';
  static String get syncTicketsEndpoint =>
      '${AppConfig.baseUrl}/events/{eventId}/tickets'; // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String organizerProfileKey = 'organizer_profile';
  static const String allowedEventIdsKey = 'allowed_event_ids';
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
