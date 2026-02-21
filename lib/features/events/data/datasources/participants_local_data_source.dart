import '../../../../core/database/participant_database.dart';
import '../models/participant_model.dart';

abstract class ParticipantsLocalDataSource {
  Future<void> cacheParticipants(
    String eventId,
    List<ParticipantModel> participants,
  );

  Future<List<ParticipantModel>> getParticipantsByEvent(String eventId);

  Future<List<ParticipantModel>> searchParticipants(
    String eventId,
    String query,
  );

  Future<void> clearParticipantsByEvent(String eventId);
}

class ParticipantsLocalDataSourceImpl implements ParticipantsLocalDataSource {
  final ParticipantDatabase _database;

  ParticipantsLocalDataSourceImpl({required ParticipantDatabase database})
    : _database = database;

  @override
  Future<void> cacheParticipants(
    String eventId,
    List<ParticipantModel> participants,
  ) async {
    // Primero limpiar los participantes anteriores
    await _database.deleteParticipantsByEvent(eventId);

    // Luego insertar los nuevos con IDs generados
    final participantMaps =
        participants.map((p) {
          final map = p.toJson();
          map['eventId'] = eventId;
          // Generar un ID único basado en eventId y ticketCorrelative
          map['id'] = '${eventId}_${p.ticketCorrelative}';
          return map;
        }).toList();

    await _database.insertParticipants(participantMaps);
  }

  @override
  Future<List<ParticipantModel>> getParticipantsByEvent(String eventId) async {
    final results = await _database.getParticipantsByEvent(eventId);
    return results.map((map) => ParticipantModel.fromJson(map)).toList();
  }

  @override
  Future<List<ParticipantModel>> searchParticipants(
    String eventId,
    String query,
  ) async {
    final results = await _database.searchParticipants(eventId, query);
    return results.map((map) => ParticipantModel.fromJson(map)).toList();
  }

  @override
  Future<void> clearParticipantsByEvent(String eventId) async {
    await _database.deleteParticipantsByEvent(eventId);
  }
}
