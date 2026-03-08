import '../../domain/entities/participant.dart';

class ParticipantModel {
  final String eventName;
  final String participantName;
  final String participantDocumentNumber;
  final String participantDocumentType;
  final String participantStatus;
  final int ticketCorrelative;
  final String ticketStatus;
  final DateTime? validatedAt;
  final String? categoryName;
  final String? ticketName;
  final DateTime purchaseDate;
  final String? runnerNumber;
  final String? chipId;
  final String? validationCode;

  ParticipantModel({
    required this.eventName,
    required this.participantName,
    required this.participantDocumentNumber,
    required this.participantDocumentType,
    required this.participantStatus,
    required this.ticketCorrelative,
    required this.ticketStatus,
    this.validatedAt,
    this.categoryName,
    this.ticketName,
    required this.purchaseDate,
    this.runnerNumber,
    this.chipId,
    this.validationCode,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      eventName: json['eventName'] ?? '',
      participantName: json['participantName'] ?? '',
      participantDocumentNumber: json['participantDocumentNumber'] ?? '',
      participantDocumentType: json['participantDocumentType'] ?? '',
      participantStatus: json['participantStatus'] ?? '',
      ticketCorrelative: json['ticketCorrelative'] ?? 0,
      ticketStatus: json['ticketStatus'] ?? '',
      validatedAt:
          json['validatedAt'] != null
              ? DateTime.parse(json['validatedAt'])
              : null,
      categoryName: json['categoryName'],
      ticketName: json['ticketName'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      runnerNumber: json['runnerNumber'],
      chipId: json['chipId'],
      validationCode: json['validationCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'participantName': participantName,
      'participantDocumentNumber': participantDocumentNumber,
      'participantDocumentType': participantDocumentType,
      'participantStatus': participantStatus,
      'ticketCorrelative': ticketCorrelative,
      'ticketStatus': ticketStatus,
      'validatedAt': validatedAt?.toIso8601String(),
      'categoryName': categoryName,
      'ticketName': ticketName,
      'purchaseDate': purchaseDate.toIso8601String(),
      'runnerNumber': runnerNumber,
      'chipId': chipId,
      'validationCode': validationCode,
    };
  }

  Participant toEntity() {
    return Participant(
      eventName: eventName,
      participantName: participantName,
      participantDocumentNumber: participantDocumentNumber,
      participantDocumentType: participantDocumentType,
      participantStatus: participantStatus,
      ticketCorrelative: ticketCorrelative,
      ticketStatus: ticketStatus,
      validatedAt: validatedAt,
      categoryName: categoryName,
      ticketName: ticketName,
      purchaseDate: purchaseDate,
      runnerNumber: runnerNumber,
      chipId: chipId,
      validationCode: validationCode,
    );
  }
}
