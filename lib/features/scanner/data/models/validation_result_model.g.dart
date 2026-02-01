// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidationResultModel _$ValidationResultModelFromJson(
        Map<String, dynamic> json) =>
    ValidationResultModel(
      eventName: json['eventName'] as String,
      participantName: json['participantName'] as String,
      participantDocument: json['participantDocument'] as String,
      documentType: json['documentType'] as String,
      ticketStatus: json['ticketStatus'] as String,
      categoryName: json['categoryName'] as String,
      ticketName: json['ticketName'] as String?,
      ticketCorrelative: (json['ticketCorrelative'] as num?)?.toInt(),
      participantStatus: json['participantStatus'] as String?,
      participantDocumentType: json['participantDocumentType'] as String?,
      participantDocumentNumber: json['participantDocumentNumber'] as String?,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      runnerNumber: json['runnerNumber'] as String?,
      chipId: json['chipId'] as String?,
      validationCode: json['validationCode'] as String?,
      isValid: json['isValid'] as bool?,
    );

Map<String, dynamic> _$ValidationResultModelToJson(
        ValidationResultModel instance) =>
    <String, dynamic>{
      'eventName': instance.eventName,
      'participantName': instance.participantName,
      'participantDocument': instance.participantDocument,
      'documentType': instance.documentType,
      'ticketStatus': instance.ticketStatus,
      'categoryName': instance.categoryName,
      'ticketName': instance.ticketName,
      'ticketCorrelative': instance.ticketCorrelative,
      'participantStatus': instance.participantStatus,
      'participantDocumentType': instance.participantDocumentType,
      'participantDocumentNumber': instance.participantDocumentNumber,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'runnerNumber': instance.runnerNumber,
      'chipId': instance.chipId,
      'validationCode': instance.validationCode,
      'isValid': instance.isValid,
    };
