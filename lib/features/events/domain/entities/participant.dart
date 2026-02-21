import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  final String eventName;
  final String participantName;
  final String participantDocumentNumber;
  final String participantDocumentType;
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final DateTime? validatedAt;
  final String? categoryName;
  final String? ticketName;
  final DateTime purchaseDate;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;

  const Participant({
    required this.eventName,
    required this.participantName,
    required this.participantDocumentNumber,
    required this.participantDocumentType,
    required this.participantStatus,
    required this.ticketCorrelative,
    required this.ticketStatus,
    this.validatedAt,
    this.categoryName,
    this.ticketName,
    required this.purchaseDate,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
  });

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    participantDocumentNumber,
    participantDocumentType,
    participantStatus,
    ticketCorrelative,
    ticketStatus,
    validatedAt,
    categoryName,
    ticketName,
    purchaseDate,
    runnerNumber,
    chipId,
    validationCode,
  ];
}
