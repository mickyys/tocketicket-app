import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import '../../core/utils/global_keys.dart';
import '../../features/auth/presentation/pages/login_page.dart';

/// Interceptor para manejar errores de autenticación globalmente
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si el servidor responde 401 Unauthorized
    if (err.response?.statusCode == 401) {
      AppLogger.warning('🚨 SESIÓN EXPIRADA: Detectado error 401 Unauthorized');
      
      // 1. Limpiar datos de sesión
      await AuthService.logout();
      
      // 2. Redirigir al login
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
    
    return super.onError(err, handler);
  }
}
