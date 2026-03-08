import 'package:google_sign_in/google_sign_in.dart';
import '../utils/logger.dart';

class GoogleSignInService {
  static GoogleSignIn? _googleSignIn;

  // Configurar Google Sign-In
  static void configure({
    List<String>? scopes,
    String? hostedDomain,
    String? clientId,
  }) {
    _googleSignIn = GoogleSignIn(
      scopes: scopes ?? ['email', 'profile'],
      hostedDomain: hostedDomain,
      clientId: clientId, // Para iOS, se configura desde iOS Runner
    );
    AppLogger.debug('🔧 Google Sign-In configurado');
  }

  // Getter para obtener la instancia de GoogleSignIn
  static GoogleSignIn get _instance {
    if (_googleSignIn == null) {
      // Auto-configurar con configuración básica si no está configurado
      configure();
    }
    return _googleSignIn!;
  }

  /// Inicia sesión con Google y retorna el ID Token
  static Future<String?> signIn() async {
    try {
      AppLogger.info('Iniciando Google Sign-In...');

      // Verificar si ya hay una sesión activa
      final currentAccount = _instance.currentUser;
      GoogleSignInAccount? account;

      if (currentAccount != null) {
        AppLogger.debug(
          'Usuario ya autenticado con Google: ${currentAccount.email}',
        );
        account = currentAccount;
      } else {
        // Iniciar proceso de login
        account = await _instance.signIn();
      }

      if (account == null) {
        AppLogger.warning('Google Sign-In cancelado por el usuario');
        return null;
      }

      AppLogger.info('Google Sign-In exitoso para: ${account.email}');

      // Obtener el token de autenticación
      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        AppLogger.error('No se pudo obtener el ID Token de Google');
        return null;
      }

      AppLogger.debug('ID Token obtenido exitosamente');
      return idToken;
    } catch (e, stackTrace) {
      AppLogger.error('Error en Google Sign-In', e, stackTrace);
      return null;
    }
  }

  /// Cierra sesión de Google
  static Future<bool> signOut() async {
    try {
      AppLogger.info('Cerrando sesión de Google...');
      await _instance.signOut();
      AppLogger.info('Google Sign-Out exitoso');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en Google Sign-Out', e, stackTrace);
      return false;
    }
  }

  /// Desconecta completamente la cuenta (revoca el acceso)
  static Future<bool> disconnect() async {
    try {
      AppLogger.info('Desconectando cuenta de Google...');
      await _instance.disconnect();
      AppLogger.info('Google disconnect exitoso');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error en Google disconnect', e, stackTrace);
      return false;
    }
  }

  /// Verifica si hay un usuario autenticado con Google
  static Future<bool> isSignedIn() async {
    try {
      return await _instance.isSignedIn();
    } catch (e) {
      AppLogger.error('Error verificando estado de Google Sign-In: $e');
      return false;
    }
  }

  /// Obtiene la información del usuario actual (si está autenticado)
  static GoogleSignInAccount? getCurrentUser() {
    try {
      return _instance.currentUser;
    } catch (e) {
      AppLogger.error('Error obteniendo usuario actual de Google: $e');
      return null;
    }
  }

  /// Silenciosamente intenta autenticar al usuario si ya había una sesión
  static Future<String?> signInSilently() async {
    try {
      AppLogger.debug('Intentando Google Sign-In silencioso...');

      final account = await _instance.signInSilently();
      if (account == null) {
        AppLogger.debug('No hay sesión previa de Google');
        return null;
      }

      AppLogger.info(
        'Google Sign-In silencioso exitoso para: ${account.email}',
      );

      final authentication = await account.authentication;
      return authentication.idToken;
    } catch (e, stackTrace) {
      AppLogger.error('Error en Google Sign-In silencioso', e, stackTrace);
      return null;
    }
  }
}
