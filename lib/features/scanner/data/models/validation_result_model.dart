import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/validation_result.dart';

part 'validation_result_model.g.dart';

@JsonSerializable()
class ValidationResultModel extends Equatable {
  final String eventName;
  final String participantName;
  @JsonKey(name: 'participantDocumentNumber')
  final String participantDocument;
  @JsonKey(name: 'participantDocumentType')
  final String documentType;
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final DateTime? validatedAt;
  final String categoryName;
  final String? ticketName;
  final DateTime? purchaseDate;
  final String? validationCode;

  const ValidationResultModel({
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

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationResultModelToJson(this);

  ValidationResult toEntity() {
    return ValidationResult(
      eventName: eventName,
      participantName: participantName,
      participantDocument: participantDocument,
      documentType: documentType,
      participantStatus: participantStatus,
      ticketCorrelative: ticketCorrelative,
      ticketStatus: ticketStatus,
      validatedAt: validatedAt,
      categoryName: categoryName,
      ticketName: ticketName,
      purchaseDate: purchaseDate,
      validationCode: validationCode,
    );
  }

  ValidationResultModel copyWith({
    String? eventName,
    String? participantName,
    String? participantDocument,
    String? documentType,
    String? participantStatus,
    int? ticketCorrelative,
    String? ticketStatus,
    DateTime? validatedAt,
    String? categoryName,
    String? ticketName,
    DateTime? purchaseDate,
    String? validationCode,
  }) {
    return ValidationResultModel(
      eventName: eventName ?? this.eventName,
      participantName: participantName ?? this.participantName,
      participantDocument: participantDocument ?? this.participantDocument,
      documentType: documentType ?? this.documentType,
      participantStatus: participantStatus ?? this.participantStatus,
      ticketCorrelative: ticketCorrelative ?? this.ticketCorrelative,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      validatedAt: validatedAt ?? this.validatedAt,
      categoryName: categoryName ?? this.categoryName,
      ticketName: ticketName ?? this.ticketName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      validationCode: validationCode ?? this.validationCode,
    );
  }

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
