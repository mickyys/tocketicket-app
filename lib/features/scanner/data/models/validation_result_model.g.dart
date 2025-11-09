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
      participantDocument: json['participantDocumentNumber'] as String,
      documentType: json['participantDocumentType'] as String,
      participantStatus: json['participantStatus'] as String,
      ticketCorrelative: (json['ticketCorrelative'] as num).toInt(),
      ticketStatus: json['ticketStatus'] as String,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      categoryName: json['categoryName'] as String,
      ticketName: json['ticketName'] as String?,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      validationCode: json['validationCode'] as String?,
    );

Map<String, dynamic> _$ValidationResultModelToJson(
        ValidationResultModel instance) =>
    <String, dynamic>{
      'eventName': instance.eventName,
      'participantName': instance.participantName,
      'participantDocumentNumber': instance.participantDocument,
      'participantDocumentType': instance.documentType,
      'participantStatus': instance.participantStatus,
      'ticketCorrelative': instance.ticketCorrelative,
      'ticketStatus': instance.ticketStatus,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'categoryName': instance.categoryName,
      'ticketName': instance.ticketName,
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'validationCode': instance.validationCode,
    };
