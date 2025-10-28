import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String address;
  final String organizerId;
  final String? imageUrl;
  final bool isActive;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.address,
    required this.organizerId,
    this.imageUrl,
    required this.isActive,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isPast => DateTime.now().isAfter(endDate);

  String get status {
    if (isUpcoming) return 'upcoming';
    if (isOngoing) return 'ongoing';
    if (isPast) return 'past';
    return 'unknown';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    startDate,
    endDate,
    location,
    address,
    organizerId,
    imageUrl,
    isActive,
    isPublic,
    createdAt,
    updatedAt,
  ];
}
