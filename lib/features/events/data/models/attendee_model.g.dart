// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendeeModel _$AttendeeModelFromJson(Map<String, dynamic> json) =>
    AttendeeModel(
      name: json['name'] as String,
      lastName: json['lastName'] as String,
      documentNumber: json['documentNumber'] as String,
      documentType: json['documentType'] as String,
      validationCode: json['validationCode'] as String,
    );

Map<String, dynamic> _$AttendeeModelToJson(AttendeeModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'lastName': instance.lastName,
      'documentNumber': instance.documentNumber,
      'documentType': instance.documentType,
      'validationCode': instance.validationCode,
    };
