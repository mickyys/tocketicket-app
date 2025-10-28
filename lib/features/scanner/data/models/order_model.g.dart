// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      ticketId: json['ticketId'] as String,
      validationCode: json['validationCode'] as String,
      status: json['status'] as String,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      validatedBy: json['validatedBy'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      participantName: json['participantName'] as String,
      participantEmail: json['participantEmail'] as String,
      participantPhone: json['participantPhone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? true,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'ticketId': instance.ticketId,
      'validationCode': instance.validationCode,
      'status': instance.status,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'validatedBy': instance.validatedBy,
      'totalAmount': instance.totalAmount,
      'participantName': instance.participantName,
      'participantEmail': instance.participantEmail,
      'participantPhone': instance.participantPhone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
    };
