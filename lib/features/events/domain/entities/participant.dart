import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  final String? orderId;
  final String eventName;
  final String participantName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String participantDocumentNumber;
  final String participantDocumentType;
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final DateTime? validatedAt;
  final String? categoryId;
  final String? categoryName;
  final String? ticketId;
  final String? ticketName;
  final DateTime purchaseDate;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;

  const Participant({
    this.orderId,
    required this.eventName,
    required this.participantName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.birthDate,
    this.gender,
    required this.participantDocumentNumber,
    required this.participantDocumentType,
    required this.participantStatus,
    required this.ticketCorrelative,
    required this.ticketStatus,
    this.validatedAt,
    this.categoryId,
    this.categoryName,
    this.ticketId,
    this.ticketName,
    required this.purchaseDate,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
  });

  @override
  List<Object?> get props => [
    orderId,
    eventName,
    participantName,
    firstName,
    lastName,
    email,
    phone,
    birthDate,
    gender,
    participantDocumentNumber,
    participantDocumentType,
    participantStatus,
    ticketCorrelative,
    ticketStatus,
    validatedAt,
    categoryId,
    categoryName,
    ticketId,
    ticketName,
    purchaseDate,
    runnerNumber,
    chipId,
    validationCode,
  ];
}
