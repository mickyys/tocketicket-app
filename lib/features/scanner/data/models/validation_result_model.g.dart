// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidationResultModel _$ValidationResultModelFromJson(
        Map<String, dynamic> json) =>
    ValidationResultModel(
      isValid: json['isValid'] as bool,
      message: json['message'] as String,
      validationCode: json['validationCode'] as String,
      status: json['status'] as String,
      eventName: json['eventName'] as String?,
      ticketName: json['ticketName'] as String?,
      participantName: json['participantName'] as String?,
      participantEmail: json['participantEmail'] as String?,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      validatedBy: json['validatedBy'] as String?,
    );

Map<String, dynamic> _$ValidationResultModelToJson(
        ValidationResultModel instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'message': instance.message,
      'validationCode': instance.validationCode,
      'status': instance.status,
      'eventName': instance.eventName,
      'ticketName': instance.ticketName,
      'participantName': instance.participantName,
      'participantEmail': instance.participantEmail,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'validatedBy': instance.validatedBy,
    };
