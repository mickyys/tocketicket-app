// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String,
      organizerId: json['organizerId'] as String,
      isActive: json['isActive'] as bool,
      isPublic: json['isPublic'] as bool,
      ticketsSold: (json['ticketsSold'] as num).toInt(),
      totalTickets: (json['totalTickets'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'location': instance.location,
      'address': instance.address,
      'imageUrl': instance.imageUrl,
      'organizerId': instance.organizerId,
      'isActive': instance.isActive,
      'isPublic': instance.isPublic,
      'ticketsSold': instance.ticketsSold,
      'totalTickets': instance.totalTickets,
      'status': instance.status,
    };
