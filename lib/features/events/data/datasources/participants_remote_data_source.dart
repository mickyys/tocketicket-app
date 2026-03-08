import 'package:dio/dio.dart';

abstract class ParticipantsRemoteDataSource {
  Future<Map<String, dynamic>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  });
}

class ParticipantsRemoteDataSourceImpl implements ParticipantsRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  ParticipantsRemoteDataSourceImpl({required this.dio, required this.baseUrl});

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
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
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
}
