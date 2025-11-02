import 'package:equatable/equatable.dart';

class ValidationResult extends Equatable {
  final String eventName;
  final String participantName;
  final String participantDocument;
  final String documentType; // 'rut' o 'pasaporte'
  final String ticketStatus;
  final String categoryName;

  const ValidationResult({
    required this.eventName,
    required this.participantName,
    required this.participantDocument,
    required this.documentType,
    required this.ticketStatus,
    required this.categoryName,
  });

  // Getter para mantener compatibilidad con código existente
  String get participantRut => participantDocument;

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    participantDocument,
    documentType,
    ticketStatus,
    categoryName,
  ];
}
