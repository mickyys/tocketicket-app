import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ParticipantsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, List<dynamic>>> searchParticipants(
    String eventId,
    String token,
    String query,
  );

  Future<Either<Failure, void>> changeParticipant(
    String orderId,
    String participantId,
    String token,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, List<dynamic>>> getEventCategories(
    String eventId,
    String token,
  );

  Future<Either<Failure, List<dynamic>>> getEventCategoriesByTicket(
    String eventId,
    String ticketId,
    String token,
  );

  Future<Either<Failure, List<dynamic>>> getEventTickets(
    String eventId,
    String token,
    bool isAdmin,
  );
}
