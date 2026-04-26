import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tocke/core/network/auth_interceptor.dart';
import 'package:tocke/core/services/auth_service.dart';
import 'package:tocke/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  test('AuthInterceptor debe hacer logout cuando recibe 401', () async {
    // Prep: Asegurar que hay una sesión activa
    await storage.write(key: AppConstants.accessTokenKey, value: 'fake_token');
    
    final interceptor = AuthInterceptor();

    // Creamos un error 401 simulado
    final dioException = DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 401,
      ),
    );

    // Ejecutamos el onError del interceptor
    interceptor.onError(dioException, ErrorInterceptorHandler());
    
    // Esperar un poco a que el async logout termine
    await Future.delayed(const Duration(milliseconds: 100));

    // Verificamos que el logout se ejecutó (token debería ser null)
    final token = await storage.read(key: AppConstants.accessTokenKey);
    expect(token, isNull);
  });
}
