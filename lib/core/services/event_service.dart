import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';
import '../constants/app_constants.dart';
import '../utils/http_header_utils.dart';
import 'auth_service.dart';
import '../../features/events/data/models/attendee_model.dart';
import '../../features/events/data/models/event_model.dart';

class EventService {
  final http.Client client;
  final String baseUrl = AppConstants.baseUrl;

  EventService({required this.client});

  /// Obtiene el token de acceso del AuthService
  Future<String> _getAuthToken() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      return token;
    }
    throw Exception('Not authenticated - please log in');
  }

  /// Obtiene los headers comunes incluyendo autenticación y plataforma
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return HttpHeaderUtils.getAuthHeaders(token);
  }

  /// Obtiene todos los asistentes de un evento con paginación
  Future<List<AttendeeModel>> fetchAllAttendees(String eventId) async {
    final List<AttendeeModel> allAttendees = [];
    int currentPage = 1;
    int totalPages = 1;

    final headers = await _getHeaders();
    final url = '$baseUrl/organizer/events/$eventId/attendees';

    AppLogger.info('Fetching attendees for event $eventId');
    AppLogger.info('Using URL: $url');
    AppLogger.info('Using Headers: $headers');

    do {
      final response = await client.get(
        Uri.parse('$url?page=$currentPage&pageSize=100'),
        headers: headers,
      );

      AppLogger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AppLogger.info('Attendees fetched successfully: ${data['data']}');
        final attendees = (data['data'] as List)
            .map((item) => AttendeeModel.fromJson(item))
            .toList();
        allAttendees.addAll(attendees);

        if (currentPage == 1) {
          totalPages = data['pagination']['totalPages'];
        }
        currentPage++;
      } else {
        throw Exception('Failed to load attendees');
      }
    } while (currentPage <= totalPages);

    return allAttendees;
  }

  /// Obtiene la lista de eventos del organizador
  Future<List<EventModel>> getEvents() async {
    final headers = await _getHeaders();

    final response = await client.get(
      Uri.parse('${AppConstants.eventsEndpoint}?page=1&pageSize=50'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final eventsData = data['data'] as List;

      return eventsData
          .map(
            (eventJson) => EventModel.fromJson({
              'id': eventJson['id'],
              'name': eventJson['name'],
              'description': eventJson['description'] ?? '',
              'startDate': eventJson['startDate'],
              'endDate': eventJson['endDate'],
              'location': _extractLocationFromAddress(eventJson['address']),
              'address': _formatFullAddress(eventJson['address']),
              'imageUrl': _extractImageUrl(eventJson['images']),
              'organizerId': eventJson['organizer']['name'] ?? '',
              'isActive': eventJson['status'] == 'active',
              'isPublic': true, // Assuming all organizer events are public
              'ticketsSold': eventJson['ticketsSold'] ?? 0,
              'totalTickets': eventJson['maxCapacity'] ?? 0,
              'status': eventJson['status'],
            }),
          )
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token expired or invalid');
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  String _extractLocationFromAddress(Map<String, dynamic>? address) {
    if (address == null) return '';
    return [
      address['street'],
      address['commune'],
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  String _formatFullAddress(Map<String, dynamic>? address) {
    if (address == null) return '';
    return [
      address['street'],
      address['commune'],
      address['region'],
      address['country'],
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  String _extractImageUrl(Map<String, dynamic>? images) {
    if (images == null) return '';

    // Try to get carousel image first, then card image
    final carousel = images['carousel'] as List?;
    if (carousel != null && carousel.isNotEmpty) {
      return carousel.first['url'] ?? '';
    }

    final card = images['card'] as List?;
    if (card != null && card.isNotEmpty) {
      return card.first['url'] ?? '';
    }

    return '';
  }
}
