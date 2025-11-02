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
    };
