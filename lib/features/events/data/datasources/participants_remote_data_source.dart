import 'package:dio/dio.dart';
import '../../../../core/services/auth_service.dart';

abstract class ParticipantsRemoteDataSource {
  Future<Map<String, dynamic>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  });

  Future<List<dynamic>> searchParticipants(
    String eventId,
    String token,
    String query,
  );

  Future<void> changeParticipant(
    String orderId,
    String participantId,
    String token,
    Map<String, dynamic> data,
  );

  Future<List<dynamic>> getEventCategories(String eventId, String token);

  Future<List<dynamic>> getEventCategoriesByTicket(String eventId, String ticketId, String token);

  Future<List<dynamic>> getEventTickets(
    String eventId,
    String token,
    bool isAdmin,
  );
}

class ParticipantsRemoteDataSourceImpl implements ParticipantsRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  ParticipantsRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  Future<Options> _buildOptions(String token) async {
    final resolvedToken =
        token.isNotEmpty ? token : await AuthService.getAccessToken() ?? '';

    if (resolvedToken.isEmpty) {
      throw Exception('Not authenticated - missing access token');
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $resolvedToken',
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/organizer/events/$eventId/participants/detailed',
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: await _buildOptions(token),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  @override
  Future<List<dynamic>> searchParticipants(
    String eventId,
    String token,
    String query,
  ) async {
    try {
      final response = await dio.get(
        '$baseUrl/organizer/events/$eventId/participants/search',
        queryParameters: {'query': query},
        options: await _buildOptions(token),
      );

      if (response.statusCode == 200) {
        return response.data is Map ? (response.data['data'] ?? []) : response.data;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  @override
  Future<void> changeParticipant(
    String orderId,
    String participantId,
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(
        '$baseUrl/organizer/orders/$orderId/participants/$participantId/change',
        data: data,
        options: await _buildOptions(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message;
      throw Exception('Network error: $message');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  @override
  Future<List<dynamic>> getEventCategories(String eventId, String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/public/events/$eventId/categories',
        queryParameters: {'page': 1, 'limit': 100},
        options: await _buildOptions(token),
      );

      if (response.statusCode == 200) {
        return response.data is Map ? (response.data['data'] ?? []) : response.data;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Obtiene categorías filtradas por ticket específico
  Future<List<dynamic>> getEventCategoriesByTicket(String eventId, String ticketId, String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/public/events/$eventId/categories',
        queryParameters: {
          'page': 1, 
          'limit': 100,
          'ticketId': ticketId,
        },
        options: await _buildOptions(token),
      );

      if (response.statusCode == 200) {
        return response.data is Map ? (response.data['data'] ?? []) : response.data;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  @override
  Future<List<dynamic>> getEventTickets(
    String eventId,
    String token,
    bool isAdmin,
  ) async {
    try {
      final response = await dio.get(
        '$baseUrl/events/$eventId/tickets',
        queryParameters: {'page': 1, 'limit': 10},
        options: await _buildOptions(token),
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
