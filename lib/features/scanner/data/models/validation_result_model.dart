import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/validation_result.dart';

part 'validation_result_model.g.dart';

@JsonSerializable()
class ValidationResultModel extends Equatable {
  final String eventName;
  final String participantName;
  final String participantDocument;
  final String documentType;
  @JsonKey(name: 'ticketStatus')
  final String ticketStatus;
  final String categoryName;

  const ValidationResultModel({
    required this.eventName,
    required this.participantName,
    required this.participantDocument,
    required this.documentType,
    required this.ticketStatus,
    required this.categoryName,
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
      ticketStatus: ticketStatus,
      categoryName: categoryName,
    );
  }

  ValidationResultModel copyWith({
    String? eventName,
    String? participantName,
    String? participantDocument,
    String? documentType,
    String? ticketStatus,
    String? categoryName,
  }) {
    return ValidationResultModel(
      eventName: eventName ?? this.eventName,
      participantName: participantName ?? this.participantName,
      participantDocument: participantDocument ?? this.participantDocument,
      documentType: documentType ?? this.documentType,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      categoryName: categoryName ?? this.categoryName,
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
  ];
}
