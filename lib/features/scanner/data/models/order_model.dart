import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String ticketId;
  final String validationCode;
  final String status;
  final DateTime? validatedAt;
  final String? validatedBy;
  final double totalAmount;
  final String participantName;
  final String participantEmail;
  final String? participantPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // For offline sync
  final bool isSynced;
  final DateTime? lastSyncAt;

  const OrderModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketId,
    required this.validationCode,
    required this.status,
    this.validatedAt,
    this.validatedBy,
    required this.totalAmount,
    required this.participantName,
    required this.participantEmail,
    this.participantPhone,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = true,
    this.lastSyncAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? ticketId,
    String? validationCode,
    String? status,
    DateTime? validatedAt,
    String? validatedBy,
    double? totalAmount,
    String? participantName,
    String? participantEmail,
    String? participantPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? lastSyncAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      ticketId: ticketId ?? this.ticketId,
      validationCode: validationCode ?? this.validationCode,
      status: status ?? this.status,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      totalAmount: totalAmount ?? this.totalAmount,
      participantName: participantName ?? this.participantName,
      participantEmail: participantEmail ?? this.participantEmail,
      participantPhone: participantPhone ?? this.participantPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    userId,
    ticketId,
    validationCode,
    status,
    validatedAt,
    validatedBy,
    totalAmount,
    participantName,
    participantEmail,
    participantPhone,
    createdAt,
    updatedAt,
    isSynced,
    lastSyncAt,
  ];
}
