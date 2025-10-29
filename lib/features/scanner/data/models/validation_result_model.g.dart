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
      participantRut: json['participantRut'] as String,
      ticketStatus: json['ticketStatus'] as String,
      categoryName: json['categoryName'] as String,
    );

Map<String, dynamic> _$ValidationResultModelToJson(
        ValidationResultModel instance) =>
    <String, dynamic>{
      'eventName': instance.eventName,
      'participantName': instance.participantName,
      'participantRut': instance.participantRut,
      'ticketStatus': instance.ticketStatus,
      'categoryName': instance.categoryName,
    };
