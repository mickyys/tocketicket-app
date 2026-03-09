import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tocke/config/app_config.dart';
import 'package:tocke/core/constants/app_constants.dart';
import '../utils/logger.dart';
import '../utils/http_header_utils.dart';
import 'auth_service.dart';
import '../../features/events/data/models/attendee_model.dart';
import '../../features/events/data/models/event_model.dart';
import '../../features/events/data/models/attendee_status_summary_model.dart';

class EventService {
  final http.Client client;
  String get baseUrl => AppConfig.baseUrl;

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
        final attendees =
            (data['data'] as List)
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

  /// Obtiene un resumen del estado de los asistentes (confirmados vs sin confirmar)
  Future<AttendeeStatusSummaryModel> getAttendeeStatusSummary(
    String eventId,
  ) async {
    final headers = await _getHeaders();
    final url = '$baseUrl/organizer/events/$eventId/attendees/status-summary';

    print('[EventService] GET $url');
    final response = await client.get(Uri.parse(url), headers: headers);
    print(
      '[EventService] status-summary response: ${response.statusCode} body: ${response.body}',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AttendeeStatusSummaryModel.fromJson(data);
    } else {
      throw Exception(
        'Failed to load attendee status summary: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Obtiene la lista de eventos del organizador
  Future<List<EventModel>> getEvents() async {
    print('EventService: getEvents called');
    final headers = await _getHeaders();
    final url =
        '${AppConstants.organizerEventsEndpoint}?page=1&pageSize=50&status=published';
    print('EventService: GET $url');

    try {
      final response = await client.get(Uri.parse(url), headers: headers);

      print('EventService: response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventsData = data['data'] as List;
        print('EventService: received ${eventsData.length} events');

        return eventsData.map((eventJson) {
          try {
            return EventModel.fromJson({
              'id': eventJson['id']?.toString() ?? '',
              'name': eventJson['name']?.toString() ?? 'Sin nombre',
              'description': eventJson['description']?.toString() ?? '',
              'startDate':
                  eventJson['startDate'] != null
                      ? DateTime.parse(eventJson['startDate']).toIso8601String()
                      : null,
              'endDate':
                  eventJson['endDate'] != null
                      ? DateTime.parse(eventJson['endDate']).toIso8601String()
                      : null,
              'location': _extractLocationFromAddress(eventJson['address']),
              'address': _formatFullAddress(eventJson['address']),
              'imageUrl': _extractImageUrl(eventJson['images']),
              'organizerId': eventJson['organizer']?['name']?.toString() ?? '',
              'isActive': eventJson['status'] == 'active',
              'isPublic': true,
              'ticketsSold': eventJson['ticketsSold'] ?? 0,
              'totalTickets': eventJson['maxCapacity'] ?? 0,
              'status': eventJson['status']?.toString() ?? 'unknown',
            });
          } catch (e) {
            print('EventService: Error mapping event ID: ${eventJson['id']}');
            print('EventService: problematic JSON node: $eventJson');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 401) {
        print('EventService: 401 Unauthorized');
        throw Exception('Unauthorized: Token expired or invalid');
      } else {
        print('EventService: Failed with status ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print('EventService: Error in getEvents: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
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
