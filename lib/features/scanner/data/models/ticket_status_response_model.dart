import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/validation_result.dart';

part 'ticket_status_response_model.g.dart';

@JsonSerializable()
class TicketStatusResponseModel extends Equatable {
  final String eventName;
  final String participantName;
  final String participantDocumentNumber;
  final String participantDocumentType;
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final String? ticketName;
  final DateTime? purchaseDate;
  final DateTime? validatedAt;
  final String? validatedByName;
  final String? categoryName;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;

  const TicketStatusResponseModel({
    required this.eventName,
    required this.participantName,
    required this.participantDocumentNumber,
    required this.participantDocumentType,
    required this.participantStatus,
    required this.ticketCorrelative,
    required this.ticketStatus,
    this.ticketName,
    this.purchaseDate,
    this.validatedAt,
    this.validatedByName,
    this.categoryName,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
  });

  factory TicketStatusResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TicketStatusResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketStatusResponseModelToJson(this);

  /// Convierte el modelo a la entidad ValidationResult esperada por la app
  ValidationResult toEntity() {
    return ValidationResult(
      eventName: eventName,
      participantName: participantName,
      ticketStatus: ticketStatus,
      categoryName: categoryName ?? '',
      ticketName: ticketName,
      ticketCorrelative: ticketCorrelative,
      participantStatus: participantStatus,
      participantDocumentType: participantDocumentType,
      participantDocumentNumber: participantDocumentNumber,
      validatedAt: null,
      validatedByName: validatedByName,
      purchaseDate: purchaseDate,
      runnerNumber: runnerNumber,
      chipId: chipId,
      validationCode: validationCode ?? '',
      isValid: ticketStatus == 'valid',
    );
  }

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    participantDocumentNumber,
    participantDocumentType,
    participantStatus,
    ticketCorrelative,
    ticketStatus,
    ticketName,
    purchaseDate,
    validatedAt,
    validatedByName,
    categoryName,
    runnerNumber,
    chipId,
    validationCode,
  ];
}
