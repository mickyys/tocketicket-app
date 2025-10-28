import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'validation_result_model.g.dart';

@JsonSerializable()
class ValidationResultModel extends Equatable {
  final bool isValid;
  final String message;
  final String validationCode;
  final String status;
  final String? eventName;
  final String? ticketName;
  final String? participantName;
  final String? participantEmail;
  final DateTime? validatedAt;
  final String? validatedBy;

  const ValidationResultModel({
    required this.isValid,
    required this.message,
    required this.validationCode,
    required this.status,
    this.eventName,
    this.ticketName,
    this.participantName,
    this.participantEmail,
    this.validatedAt,
    this.validatedBy,
  });

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationResultModelToJson(this);

  ValidationResultModel copyWith({
    bool? isValid,
    String? message,
    String? validationCode,
    String? status,
    String? eventName,
    String? ticketName,
    String? participantName,
    String? participantEmail,
    DateTime? validatedAt,
    String? validatedBy,
  }) {
    return ValidationResultModel(
      isValid: isValid ?? this.isValid,
      message: message ?? this.message,
      validationCode: validationCode ?? this.validationCode,
      status: status ?? this.status,
      eventName: eventName ?? this.eventName,
      ticketName: ticketName ?? this.ticketName,
      participantName: participantName ?? this.participantName,
      participantEmail: participantEmail ?? this.participantEmail,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
    );
  }

  @override
  List<Object?> get props => [
    isValid,
    message,
    validationCode,
    status,
    eventName,
    ticketName,
    participantName,
    participantEmail,
    validatedAt,
    validatedBy,
  ];
}
