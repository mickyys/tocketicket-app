import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String address;
  final String imageUrl;
  final String organizerId;
  final bool isActive;
  final bool isPublic;
  final int ticketsSold;
  final int totalTickets;
  final String status;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.address,
    required this.imageUrl,
    required this.organizerId,
    required this.isActive,
    required this.isPublic,
    required this.ticketsSold,
    required this.totalTickets,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        location,
        address,
        imageUrl,
        organizerId,
        isActive,
        isPublic,
        ticketsSold,
        totalTickets,
        status,
      ];
}
