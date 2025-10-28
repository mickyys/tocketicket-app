import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/auth_service.dart';
import '../models/attendee_model.dart';

abstract class EventRemoteDataSource {
  Future<List<AttendeeModel>> fetchAllAttendees(String eventId);
  Future<List<EventModel>> getEvents();
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://localhost:8080/organizer/events';

  EventRemoteDataSourceImpl({required this.client});

  @override
  Future<List<AttendeeModel>> fetchAllAttendees(String eventId) async {
    final List<AttendeeModel> allAttendees = [];
    int currentPage = 1;
    int totalPages = 1;

    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    do {
      final response = await client.get(
        Uri.parse('$baseUrl/$eventId/attendees?page=$currentPage&pageSize=100'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  @override
  Future<List<EventModel>> getEvents() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return mock data
    return [
      EventModel(
        id: '1',
        name: 'Concierto de Rock 2025',
        description: '',
        startDate: DateTime.parse('2025-11-15'),
        endDate: DateTime.parse('2025-11-15'),
        location: 'Estadio Nacional',
        address: '',
        imageUrl: '',
        organizerId: '',
        isActive: true,
        isPublic: true,
        ticketsSold: 1250,
        totalTickets: 2000,
        status: 'active',
      ),
      EventModel(
        id: '2',
        name: 'Festival de Jazz',
        description: '',
        startDate: DateTime.parse('2025-12-01'),
        endDate: DateTime.parse('2025-12-01'),
        location: 'Centro Cultural',
        address: '',
        imageUrl: '',
        organizerId: '',
        isActive: true,
        isPublic: true,
        ticketsSold: 850,
        totalTickets: 1500,
        status: 'active',
      ),
      EventModel(
        id: '3',
        name: 'Obra de Teatro',
        description: '',
        startDate: DateTime.parse('2025-10-30'),
        endDate: DateTime.parse('2025-10-30'),
        location: 'Teatro Municipal',
        address: '',
        imageUrl: '',
        organizerId: '',
        isActive: false,
        isPublic: true,
        ticketsSold: 180,
        totalTickets: 200,
        status: 'sold_out',
      ),
    ];
  }
}
