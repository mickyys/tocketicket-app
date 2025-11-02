import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/http_header_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/validation_result_model.dart';

abstract class TicketRemoteDataSource {
  /// Consulta el estado de un ticket usando el código de validación
  /// Endpoint: GET /tickets/status/:validationCode
  Future<ValidationResultModel> checkTicketStatus(String validationCode);

  /// Valida un ticket QR y lo marca como usado
  /// Endpoint: POST /tickets/validate-qr
  /// Body: {"validationCode": "code"}
  Future<ValidationResultModel> validateTicketQR(String validationCode);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final http.Client client;

  TicketRemoteDataSourceImpl({required this.client});

  @override
  Future<ValidationResultModel> checkTicketStatus(String validationCode) async {
    try {
      AppLogger.info('Consultando estado del ticket: $validationCode');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw ServerException('Token de autenticación no disponible');
      }

      final url = '${AppConstants.ticketStatusEndpoint}/$validationCode';
      AppLogger.debug('URL de consulta: $url');

      final response = await client
          .get(Uri.parse(url), headers: HttpHeaderUtils.getAuthHeaders(token))
          .timeout(AppConstants.connectTimeout);

      AppLogger.info('Respuesta del servidor: ${response.statusCode}');
      AppLogger.debug('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ValidationResultModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw ServerException('Ticket no encontrado');
      } else if (response.statusCode == 401) {
        throw ServerException('Token de autenticación inválido');
      } else {
        final responseData = jsonDecode(response.body);
        throw ServerException(
          responseData['message'] ?? 'Error al consultar el estado del ticket',
        );
      }
    } catch (e) {
      AppLogger.error('Error consultando estado del ticket: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error de conexión: $e');
    }
  }

  @override
  Future<ValidationResultModel> validateTicketQR(String validationCode) async {
    try {
      AppLogger.info('Validando ticket QR: $validationCode');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw ServerException('Token de autenticación no disponible');
      }

      final url = AppConstants.validateTicketEndpoint;
      AppLogger.debug('URL de validación: $url');

      final requestBody = jsonEncode({'validationCode': validationCode});
      AppLogger.debug('Cuerpo de solicitud: $requestBody');

      final response = await client
          .post(
            Uri.parse(url),
            headers: HttpHeaderUtils.getAuthHeaders(token),
            body: requestBody,
          )
          .timeout(AppConstants.connectTimeout);

      AppLogger.info('Respuesta del servidor: ${response.statusCode}');
      AppLogger.debug('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ValidationResultModel.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        throw ServerException(responseData['message'] ?? 'Ticket inválido');
      } else if (response.statusCode == 404) {
        throw ServerException('Ticket no encontrado');
      } else if (response.statusCode == 401) {
        throw ServerException('Token de autenticación inválido');
      } else {
        final responseData = jsonDecode(response.body);
        throw ServerException(
          responseData['message'] ?? 'Error al validar el ticket',
        );
      }
    } catch (e) {
      AppLogger.error('Error validando ticket QR: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error de conexión: $e');
    }
  }
}
