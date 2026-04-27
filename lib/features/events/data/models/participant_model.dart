import '../../domain/entities/participant.dart';

class ParticipantModel {
  final String? orderId;
  final String eventName;
  final String participantName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String participantDocumentNumber;
  final String participantDocumentType;
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final DateTime? validatedAt;
  final String? categoryId;
  final String? categoryName;
  final String? ticketId;
  final String? ticketName;
  final DateTime purchaseDate;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;

  ParticipantModel({
    this.orderId,
    required this.eventName,
    required this.participantName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.birthDate,
    this.gender,
    required this.participantDocumentNumber,
    required this.participantDocumentType,
    required this.participantStatus,
    required this.ticketCorrelative,
    required this.ticketStatus,
    this.validatedAt,
    this.categoryId,
    this.categoryName,
    this.ticketId,
    this.ticketName,
    required this.purchaseDate,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      orderId: json['orderId'],
      eventName: json['eventName'] ?? '',
      participantName: json['participantName'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'],
      gender: json['gender'],
      participantDocumentNumber: json['participantDocumentNumber'] ?? '',
      participantDocumentType: json['participantDocumentType'] ?? '',
      participantStatus: json['participantStatus'] ?? '',
      ticketCorrelative: json['ticketCorrelative'] ?? 0,
      ticketStatus: json['ticketStatus'] ?? '',
      validatedAt:
          json['validatedAt'] != null
              ? DateTime.parse(json['validatedAt'])
              : null,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      ticketId: json['ticketId'],
      ticketName: json['ticketName'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      runnerNumber: json['runnerNumber'],
      chipId: json['chipId'],
      validationCode: json['validationCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'eventName': eventName,
      'participantName': participantName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'participantDocumentNumber': participantDocumentNumber,
      'participantDocumentType': participantDocumentType,
      'participantStatus': participantStatus,
      'ticketCorrelative': ticketCorrelative,
      'ticketStatus': ticketStatus,
      'validatedAt': validatedAt?.toIso8601String(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'ticketId': ticketId,
      'ticketName': ticketName,
      'purchaseDate': purchaseDate.toIso8601String(),
      'runnerNumber': runnerNumber,
      'chipId': chipId,
      'validationCode': validationCode,
    };
  }

  Participant toEntity() {
    return Participant(
      orderId: orderId,
      eventName: eventName,
      participantName: participantName,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      birthDate: birthDate,
      gender: gender,
      participantDocumentNumber: participantDocumentNumber,
      participantDocumentType: participantDocumentType,
      participantStatus: participantStatus,
      ticketCorrelative: ticketCorrelative,
      ticketStatus: ticketStatus,
      validatedAt: validatedAt,
      categoryId: categoryId,
      categoryName: categoryName,
      ticketId: ticketId,
      ticketName: ticketName,
      purchaseDate: purchaseDate,
      runnerNumber: runnerNumber,
      chipId: chipId,
      validationCode: validationCode,
    );
  }
}
