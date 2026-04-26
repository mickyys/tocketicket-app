import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/validation_result_model.dart';
import '../models/ticket_status_response_model.dart';

abstract class TicketRemoteDataSource {
  Future<ValidationResultModel> checkTicketStatus(String validationCode);
  Future<ValidationResultModel> validateTicketQR(String validationCode);
  Future<ValidationResultModel> updateTicketRunnerData(
    String validationCode,
    String runnerNumber,
    String chipId,
  );
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final Dio dio;

  TicketRemoteDataSourceImpl({required this.dio});

  @override
  Future<ValidationResultModel> checkTicketStatus(String validationCode) async {
    try {
      AppLogger.info('Consultando estado del ticket (Dio): $validationCode');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw ServerException('Token de autenticación no disponible');
      }

      final response = await dio.get(
        '${AppConstants.ticketStatusEndpoint}/$validationCode',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final ticketStatusResponse = TicketStatusResponseModel.fromJson(
          response.data,
        );
        return ValidationResultModel(
          eventName: ticketStatusResponse.eventName,
          participantName: ticketStatusResponse.participantName,
          participantDocument: ticketStatusResponse.participantDocumentNumber,
          documentType: ticketStatusResponse.participantDocumentType,
          ticketStatus: ticketStatusResponse.ticketStatus,
          categoryName: ticketStatusResponse.categoryName ?? '',
          ticketName: ticketStatusResponse.ticketName,
          ticketCorrelative: ticketStatusResponse.ticketCorrelative,
          participantStatus: ticketStatusResponse.participantStatus,
          participantDocumentType: ticketStatusResponse.participantDocumentType,
          participantDocumentNumber:
              ticketStatusResponse.participantDocumentNumber,
          validatedAt: ticketStatusResponse.validatedAt,
          validatedByName: ticketStatusResponse.validatedByName,
          purchaseDate: ticketStatusResponse.purchaseDate,
          runnerNumber: ticketStatusResponse.runnerNumber ?? '',
          chipId: ticketStatusResponse.chipId ?? '',
          validationCode: ticketStatusResponse.validationCode ?? validationCode,
          isValid: ticketStatusResponse.ticketStatus == 'valid',
          enableChipId: ticketStatusResponse.enableChipId ?? false,
          enableRunnerNumber: ticketStatusResponse.enableRunnerNumber ?? false,
        );
      } else {
        throw ServerException('Error inesperado: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      AppLogger.error('Error inesperado en checkTicketStatus: $e');
      throw ServerException('Error de conexión: $e');
    }
  }

  @override
  Future<ValidationResultModel> validateTicketQR(String validationCode) async {
    try {
      AppLogger.info('Validando ticket QR (Dio): $validationCode');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw ServerException('Token de autenticación no disponible');
      }

      final response = await dio.post(
        AppConstants.validateTicketEndpoint,
        data: {'validationCode': validationCode},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ValidationResultModel.fromJson(response.data);
      } else {
        throw ServerException('Error inesperado: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      AppLogger.error('Error inesperado en validateTicketQR: $e');
      throw ServerException('Error de conexión: $e');
    }
  }

  @override
  Future<ValidationResultModel> updateTicketRunnerData(
    String validationCode,
    String runnerNumber,
    String chipId,
  ) async {
    try {
      AppLogger.info('Actualizando datos de corredor (Dio): $validationCode');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw ServerException('Token de autenticación no disponible');
      }

      final response = await dio.post(
        AppConstants.validateTicketEndpoint,
        data: {
          'validationCode': validationCode,
          'runnerNumber': runnerNumber,
          'chipId': chipId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ValidationResultModel.fromJson(response.data);
      } else {
        throw ServerException('Error inesperado: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      AppLogger.error('Error inesperado en updateTicketRunnerData: $e');
      throw ServerException('Error de conexión: $e');
    }
  }

  void _handleDioError(DioException e) {
    AppLogger.error('Error de API (Dio): ${e.type} - ${e.message}');
    
    if (e.response?.statusCode == 404) {
      throw ServerException('Ticket no encontrado');
    } else if (e.response?.statusCode == 401) {
      throw ServerException('Token de autenticación inválido');
    } else if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Solicitud inválida';
      throw ServerException(message);
    }
    
    final message = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Error al procesar la solicitud';
    throw ServerException(message);
  }
}
