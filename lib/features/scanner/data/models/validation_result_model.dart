import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/validation_result.dart';

part 'validation_result_model.g.dart';

@JsonSerializable()
class ValidationResultModel extends Equatable {
  @JsonKey(defaultValue: '')
  final String eventName;
  @JsonKey(defaultValue: '')
  final String participantName;
  @JsonKey(name: 'participantDocumentNumber', defaultValue: '')
  final String participantDocument;
  @JsonKey(name: 'participantDocumentType', defaultValue: '')
  final String documentType;
  @JsonKey(name: 'ticketStatus', defaultValue: '')
  final String ticketStatus;
  @JsonKey(defaultValue: '')
  final String categoryName;
  final String? ticketName;
  final int? ticketCorrelative;
  final String? participantStatus;
  final String? participantDocumentType;
  final String? participantDocumentNumber;
  final DateTime? validatedAt;
  final DateTime? purchaseDate;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;
  final bool? isValid;

  const ValidationResultModel({
    required this.eventName,
    required this.participantName,
    required this.participantDocument,
    required this.documentType,
    required this.ticketStatus,
    required this.categoryName,
    this.ticketName,
    this.ticketCorrelative,
    this.participantStatus,
    this.participantDocumentType,
    this.participantDocumentNumber,
    this.validatedAt,
    this.purchaseDate,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
    this.isValid,
  });

  // Getter para mantener compatibilidad con código existente
  String get participantRut => participantDocument;

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationResultModelToJson(this);

  ValidationResult toEntity() {
    return ValidationResult(
      eventName: eventName,
      participantName: participantName,
      ticketStatus: ticketStatus,
      categoryName: categoryName,
      ticketName: ticketName,
      ticketCorrelative: ticketCorrelative,
      participantStatus: participantStatus,
      participantDocumentType: participantDocumentType,
      participantDocumentNumber: participantDocumentNumber,
      validatedAt: validatedAt,
      purchaseDate: purchaseDate,
      runnerNumber: runnerNumber,
      chipId: chipId,
      validationCode: validationCode,
      isValid: isValid ?? (ticketStatus == 'valid'),
    );
  }

  ValidationResultModel copyWith({
    String? eventName,
    String? participantName,
    String? participantDocument,
    String? documentType,
    String? ticketStatus,
    String? categoryName,
    String? ticketName,
    int? ticketCorrelative,
    String? participantStatus,
    String? participantDocumentType,
    String? participantDocumentNumber,
    DateTime? validatedAt,
    DateTime? purchaseDate,
    String? runnerNumber,
    String? chipId,
    String? validationCode,
    bool? isValid,
  }) {
    return ValidationResultModel(
      eventName: eventName ?? this.eventName,
      participantName: participantName ?? this.participantName,
      participantDocument: participantDocument ?? this.participantDocument,
      documentType: documentType ?? this.documentType,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      categoryName: categoryName ?? this.categoryName,
      ticketName: ticketName ?? this.ticketName,
      ticketCorrelative: ticketCorrelative ?? this.ticketCorrelative,
      participantStatus: participantStatus ?? this.participantStatus,
      participantDocumentType:
          participantDocumentType ?? this.participantDocumentType,
      participantDocumentNumber:
          participantDocumentNumber ?? this.participantDocumentNumber,
      validatedAt: validatedAt ?? this.validatedAt,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      runnerNumber: runnerNumber ?? this.runnerNumber,
      chipId: chipId ?? this.chipId,
      validationCode: validationCode ?? this.validationCode,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    participantDocument,
    documentType,
    ticketStatus,
    categoryName,
    ticketName,
    ticketCorrelative,
    participantStatus,
    participantDocumentType,
    participantDocumentNumber,
    validatedAt,
    purchaseDate,
    runnerNumber,
    chipId,
    validationCode,
    isValid,
  ];
}
