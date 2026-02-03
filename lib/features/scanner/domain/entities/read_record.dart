import 'package:equatable/equatable.dart';

class ReadRecord extends Equatable {
  final String id;
  final String ticketId;
  final String participantName;
  final String eventName;
  final DateTime timestamp;
  final String runnerNumber;
  final String chipId;
  final bool isFirstTime;

  const ReadRecord({
    required this.id,
    required this.ticketId,
    required this.participantName,
    required this.eventName,
    required this.timestamp,
    required this.runnerNumber,
    required this.chipId,
    required this.isFirstTime,
  });

  @override
  List<Object?> get props => [
    id,
    ticketId,
    participantName,
    eventName,
    timestamp,
    runnerNumber,
    chipId,
    isFirstTime,
  ];

  // Convertir a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'participantName': participantName,
      'eventName': eventName,
      'timestamp': timestamp.toIso8601String(),
      'runnerNumber': runnerNumber,
      'chipId': chipId,
      'isFirstTime': isFirstTime,
    };
  }

  // Crear desde JSON
  factory ReadRecord.fromJson(Map<String, dynamic> json) {
    return ReadRecord(
      id: json['id'] ?? '',
      ticketId: json['ticketId'] ?? '',
      participantName: json['participantName'] ?? '',
      eventName: json['eventName'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      runnerNumber: json['runnerNumber'] ?? '',
      chipId: json['chipId'] ?? '',
      isFirstTime: json['isFirstTime'] ?? false,
    );
  }
}
