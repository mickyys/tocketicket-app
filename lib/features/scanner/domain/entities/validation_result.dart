import 'package:equatable/equatable.dart';

class ValidationResult extends Equatable {
  final String eventName;
  final String participantName;
  final String participantDocument;
  final String documentType; // 'rut' o 'pasaporte'
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final DateTime? validatedAt;
  final String categoryName;
  final String? ticketName;
  final DateTime? purchaseDate;
  final String? validationCode;

  const ValidationResult({
    required this.eventName,
    required this.participantName,
    required this.participantDocument,
    required this.documentType,
    required this.participantStatus,
    required this.ticketCorrelative,
    required this.ticketStatus,
    this.validatedAt,
    required this.categoryName,
    this.ticketName,
    this.purchaseDate,
    this.validationCode,
  });

  // Getter para mantener compatibilidad con código existente
  String get participantRut => participantDocument;

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    participantDocument,
    documentType,
    participantStatus,
    ticketCorrelative,
    ticketStatus,
    validatedAt,
    categoryName,
    ticketName,
    purchaseDate,
    validationCode,
  ];
}
