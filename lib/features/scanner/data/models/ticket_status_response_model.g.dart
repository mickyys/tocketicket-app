// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_status_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketStatusResponseModel _$TicketStatusResponseModelFromJson(
  Map<String, dynamic> json,
) => TicketStatusResponseModel(
  eventName: json['eventName'] as String,
  participantName: json['participantName'] as String,
  participantDocumentNumber: json['participantDocumentNumber'] as String,
  participantDocumentType: json['participantDocumentType'] as String,
  participantStatus: json['participantStatus'] as String,
  ticketCorrelative: (json['ticketCorrelative'] as num).toInt(),
  ticketStatus: json['ticketStatus'] as String,
  ticketName: json['ticketName'] as String?,
  purchaseDate:
      json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
  validatedAt:
      json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
  validatedByName: json['validatedByName'] as String?,
  categoryName: json['categoryName'] as String?,
  runnerNumber: json['runnerNumber'] as String?,
  chipId: json['chipId'] as String?,
  validationCode: json['validationCode'] as String?,
  enableChipId: json['enableChipId'] as bool?,
  enableRunnerNumber: json['enableRunnerNumber'] as bool?,
);

Map<String, dynamic> _$TicketStatusResponseModelToJson(
  TicketStatusResponseModel instance,
) => <String, dynamic>{
  'eventName': instance.eventName,
  'participantName': instance.participantName,
  'participantDocumentNumber': instance.participantDocumentNumber,
  'participantDocumentType': instance.participantDocumentType,
  'participantStatus': instance.participantStatus,
  'ticketCorrelative': instance.ticketCorrelative,
  'ticketStatus': instance.ticketStatus,
  'ticketName': instance.ticketName,
  'purchaseDate': instance.purchaseDate?.toIso8601String(),
  'validatedAt': instance.validatedAt?.toIso8601String(),
  'validatedByName': instance.validatedByName,
  'categoryName': instance.categoryName,
  'runnerNumber': instance.runnerNumber,
  'chipId': instance.chipId,
  'validationCode': instance.validationCode,
  'enableChipId': instance.enableChipId,
  'enableRunnerNumber': instance.enableRunnerNumber,
};
