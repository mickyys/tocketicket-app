import 'package:equatable/equatable.dart';

class ValidationResult extends Equatable {
  final String eventName;
  final String participantName;
  final String ticketStatus;
  final String categoryName;
  final String? ticketName;
  final int? ticketCorrelative;
  final String? participantStatus;
  final String? participantDocumentType;
  final String? participantDocumentNumber;
  final DateTime? validatedAt;
  final String? validatedByName;
  final DateTime? purchaseDate;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;
  final bool isValid;

  const ValidationResult({
    required this.eventName,
    required this.participantName,
    required this.ticketStatus,
    required this.categoryName,
    this.ticketName,
    this.ticketCorrelative,
    this.participantStatus,
    this.participantDocumentType,
    this.participantDocumentNumber,
    this.validatedAt,
    this.validatedByName,
    this.purchaseDate,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
    this.isValid = true,
  });

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    ticketStatus,
    categoryName,
    ticketName,
    ticketCorrelative,
    participantStatus,
    participantDocumentType,
    participantDocumentNumber,
    validatedAt,
    validatedByName,
    purchaseDate,
    runnerNumber,
    chipId,
    validationCode,
    isValid,
  ];
}
