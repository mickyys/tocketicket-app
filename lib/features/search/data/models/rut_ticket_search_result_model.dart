import 'package:tocke/features/scanner/domain/entities/validation_result.dart';
import 'package:tocke/features/events/domain/entities/participant.dart';
import 'package:tocke/features/events/domain/entities/event.dart';

class RutTicketSearchResultModel {
  final String orderId;
  final String eventId;
  final String eventName;
  final DateTime? eventDate;
  final String eventLocation;
  final String participantName;
  final String documentType;
  final String documentNumber;
  final String email;
  final String phone;
  final String ticketId;
  final String ticketName;
  final String categoryId;
  final String categoryName;
  final String validationCode;
  final String participantStatus;
  final String ticketStatus;
  final DateTime? validatedAt;
  final DateTime purchaseDate;
  final String? birthDate;
  final String? gender;

  const RutTicketSearchResultModel({
    required this.orderId,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.participantName,
    required this.documentType,
    required this.documentNumber,
    required this.email,
    required this.phone,
    required this.ticketId,
    required this.ticketName,
    required this.categoryId,
    required this.categoryName,
    required this.validationCode,
    required this.participantStatus,
    required this.ticketStatus,
required this.validatedAt,
    required this.purchaseDate,
    this.birthDate,
    this.gender,
  });

  factory RutTicketSearchResultModel.fromJson(Map<String, dynamic> json) {
    return RutTicketSearchResultModel(
      orderId: json['orderId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? '',
      eventDate:
          json['eventDate'] != null
              ? DateTime.tryParse(json['eventDate'].toString())
              : null,
      eventLocation: json['eventLocation']?.toString() ?? '',
      participantName: json['participantName']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      documentNumber: json['documentNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      ticketName: json['ticketName']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      validationCode: json['validationCode']?.toString() ?? '',
      participantStatus: json['participantStatus']?.toString() ?? '',
      ticketStatus: json['ticketStatus']?.toString() ?? '',
      validatedAt:
          json['validatedAt'] != null
              ? DateTime.tryParse(json['validatedAt'].toString())
              : null,
      purchaseDate:
          DateTime.tryParse(json['purchaseDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      birthDate: json['birthDate']?.toString(),
      gender: json['gender']?.toString(),
    );
  }

  ValidationResult toValidationResult() {
    return ValidationResult(
      eventName: eventName,
      participantName: participantName,
      ticketStatus: ticketStatus,
      categoryName: categoryName,
      ticketName: ticketName,
      ticketCorrelative: int.tryParse(ticketId),
      participantStatus: participantStatus,
      participantDocumentType: documentType,
      participantDocumentNumber: documentNumber,
      validatedAt: validatedAt,
      purchaseDate: purchaseDate,
      validationCode: validationCode,
      isValid: ticketStatus == 'valid',
      enableChipId: false, // Default for now
      enableRunnerNumber: false, // Default for now
    );
  }

  Participant toParticipant() {
    // Intentar separar nombre y apellido si es necesario
    String fname = '';
    String lname = '';
    if (participantName.isNotEmpty) {
      final parts = participantName.trim().split(' ');
      if (parts.length > 1) {
        fname = parts[0];
        lname = parts.sublist(1).join(' ');
      } else {
        fname = parts[0];
      }
    }

    return Participant(
      orderId: orderId,
      eventName: eventName,
      participantName: participantName,
      firstName: fname,
      lastName: lname,
      email: email,
      phone: phone,
      birthDate: birthDate,
      gender: gender,
      participantDocumentNumber: documentNumber,
      participantDocumentType: documentType.toLowerCase(),
      participantStatus: participantStatus,
      ticketCorrelative: int.tryParse(ticketId) ?? 0,
      ticketStatus: ticketStatus,
      validatedAt: validatedAt,
      categoryId: categoryId,
      categoryName: categoryName,
      ticketId: ticketId,
      ticketName: ticketName,
      purchaseDate: purchaseDate,
      validationCode: validationCode,
    );
  }

  Event toEvent() {
    return Event(
      id: eventId,
      name: eventName,
      description: '',
      location: eventLocation,
      address: '',
      imageUrl: '',
      organizerId: '',
      isActive: true,
      isPublic: false,
      ticketsSold: 0,
      totalTickets: 0,
      status: 'active',
    );
  }
}
